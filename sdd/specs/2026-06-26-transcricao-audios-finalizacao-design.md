# Transcrição de áudios na finalização de ticket por IA (via Whisper)

**Data:** 2026-06-26 · **Tipo:** REFACT/Feature · **Área:** Back · **Card Monday:** 12331121080
**Frente:** `feat/transcricao-audios-finalizacao` · **Repos:** neo-api-pharmachatbot, api-pharmachatbot · base `develop`

## 1. Problema

Na finalização de ticket por IA (autofill do CRM, `ai-crm-autofill.service.ts` no neo), os áudios da
conversa são transcritos hoje pela própria IA — o `AudioAgent` envia o áudio em base64 (`input_audio`)
para o modelo multimodal de áudio da OpenAI. Caminho caro: a IA "ouve" o áudio só para extrair texto
que vai compor o transcript do autofill.

## 2. Objetivo

Trocar essa transcrição pelo microsserviço **Whisper** (já implantado em prod, GPU via RunPod), de modo
que o LLM de autofill receba **apenas texto**, sob uma **feature flag por empresa** (`Transcrição de Áudios`).
Meta: reduzir custo de transcrição na finalização, com rollout controlado por empresa.

## 3. Decisões (do brainstorm)

- **Sempre transcreve via Whisper** quando a flag está ON (sem heurística de "duas passadas").
- **Flag OFF = não transcreve nada**: áudios são ignorados no transcript; o autofill roda só com texto.
  Consequência aceita: a transcrição OpenAI sai da finalização para quem não ativou a flag — autofill
  degrada até a flag ser ligada. Recomenda-se ligar por empresa no rollout.
- **Chamada síncrona em lote** (`POST /transcribe-batch`) dentro do fluxo de finalização (não é tempo-real).
- **Web fora de escopo**: a flag é ligada pela página `FeatureFlags` genérica que já existe.
- **AudioAgent permanece**: também é consumido por `ai-conversation.orchestrator.ts` (transcrição em
  tempo real). Apenas a finalização deixa de usá-lo.

## 4. Escopo

### Dentro
- **api-pharmachatbot:** seed da flag `Transcrição de Áudios` em `feature_flags` (padrão do seed
  `insights-de-vendas`). Tabelas `feature_flags` / `company_feature_flags` já existem — sem migration nova.
- **neo-api-pharmachatbot:**
  - Novo `WhisperClient` (service) — primeiro client HTTP interno do projeto; `fetch` nativo com
    `Authorization: Bearer ${WHISPER_API_TOKEN}` para `${WHISPER_BASE_URL}/transcribe-batch`. Montado por
    `useFactory` + `inject: [ConfigService]`, espelhando o `LlmModule`.
  - Config: `WHISPER_BASE_URL`, `WHISPER_API_TOKEN` no `.env.example` + factory de config.
  - `ai-crm-autofill.service.ts`: aplicar gating pela flag e trocar o caminho de transcrição (detalhe §5).
  - Atualizar `ai-crm-autofill.service.test.ts`.

### Fora
- Web (UI), botão de transcrição na conversa, `AudioAgent`/orchestrator, LLM/prompt do autofill,
  transcrição via fila assíncrona, tradução/resumo de áudio.

## 5. Fluxo no autofill (`ai-crm-autofill.service.ts`)

1. No início da finalização, checar a flag: `featureFlagService.checkFeatureAccess(companyId, 'Transcrição de Áudios')`.
2. **Flag OFF:** `buildTranscript` ignora mensagens de áudio (sem `body`); usa só as de texto.
3. **Flag ON:**
   - Coletar mensagens de áudio **pendentes**: `mediaType === 'audio' && mediaUrl` e `body` vazio
     (as já transcritas têm `body` preenchido → reuso automático, não reprocessa).
   - Um `POST /transcribe-batch` com `{ items: [{ messageId: message.id, audioUrl: mediaUrl }], type: 'gpu' }`.
   - Para cada item de retorno, persistir `text` em `message.body` via `messageRepository.updateMessage(messageId, { body })`.
   - `buildTranscript` monta o texto (agora todas as mensagens relevantes têm `body`).
4. Transcript (texto) segue para o LLM de autofill — **inalterado**.

## 6. Contrato do Whisper (já implantado)

`POST /transcribe-batch` — `Authorization: Bearer <WHISPER_API_TOKEN>`
```json
{ "items": [ { "messageId": "msg-1", "audioUrl": "https://.../a.ogg" } ], "type": "gpu" }
```
Resposta `200` (lista, mesma ordem):
```json
[ { "messageId": "msg-1", "text": "...", "language": "pt", "durationMs": 1200, "engine": "gpu" } ]
```
- `audioUrl` deve ser **HTTPS** (fetcher com defesa SSRF; allowlist via `WHISPER_ALLOWED_HOSTS`, hoje `*`).
- Limites: 25 MB / 300 s por áudio; erros: 400 (URL inválida/SSRF), 413 (tamanho), 429 (concorrência),
  502 (GPU/fetch), 504 (timeout fetch).
- URL in-cluster (prod): `http://whisper-pharmachatbot-pharma.pharmachatbot.svc.cluster.local:8000`.

## 7. Resiliência (RF4)

- Falha do batch (timeout/502/429/etc) → ignora os áudios daquela finalização; o autofill prossegue só com
  texto. Nunca quebra a finalização.
- Log de sucesso/falha por finalização (sem vazar conteúdo sensível).
- **Em aberto (simples por ora):** a resposta do batch não define erro por item. Tratamos falha do batch
  como "ignora todos os áudios". Fallback por item (`/transcribe` single) fica como melhoria futura se
  necessário — não implementar agora (YAGNI).

## 8. Critérios de aceitação

- Com a flag ON, áudios da conversa são transcritos via Whisper na finalização e o LLM recebe só texto.
- Transcrições são persistidas em `message.body` e reutilizadas (não reprocessa áudio já transcrito).
- Com a flag OFF, nenhum áudio é transcrito na finalização (autofill só com texto).
- Falha de transcrição não quebra o autofill.
- `ai-crm-autofill.service.test.ts` cobre: flag ON (batch + persist), flag OFF (ignora áudio), falha do batch.

## 9. Métricas

- Custo médio por finalização (antes vs depois).
- Taxa de sucesso de transcrição na finalização.
- Estabilidade da qualidade do autofill (não regredir de forma relevante).

## 10. Riscos / notas de deploy

- O neo precisa de `WHISPER_BASE_URL` + `WHISPER_API_TOKEN` no ambiente (config/secret no deploy do neo —
  infra, fora desta frente de código). O `WHISPER_API_TOKEN` é o mesmo Bearer do secret
  `whisper-pharmachatbot-secret` no namespace `pharmachatbot`.
- `mediaUrl` dos áudios precisa ser HTTPS e alcançável pelo pod do Whisper.
