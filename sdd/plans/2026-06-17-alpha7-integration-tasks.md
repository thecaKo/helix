# Alpha7 Integration — Plano de Implementação

**Goal:** Implementar integração com banco intermediário Alpha7 (catálogo + estoque), reutilizando canônicas HOS, com pool de 10 conexões compartilhado e sync incremental por cursor timestamp.
**Arquitetura:** módulo `alpha7-integration` independente no neo-api; page + serviço web espelhando HOS. Repositórios canônicos (`integration_products`, `integration_product_stock`) são reutilizados sem cópia.
**Stack:** NestJS (neo-api), React (web-pharmachatbot), `pg` ou `mysql2` para conexão ao banco intermediário.
**Spec:** `sdd/specs/2026-06-17-alpha7-integration-design.md`

---

## Context Pack

### Comandos (neo-api-pharmachatbot)
```bash
cd worktrees/feat-alpha7-integration/neo-api-pharmachatbot
pnpm test              # vitest
pnpm build             # tsc
pnpm lint              # biome
pnpm test <arquivo>    # teste isolado
```

### Comandos (web-pharmachatbot)
```bash
cd worktrees/feat-alpha7-integration/web-pharmachatbot
pnpm test              # vitest
pnpm build             # vite build
pnpm lint              # biome
```

### Variáveis de ambiente (neo-api)
```
ALPHA7_DB_TYPE     = postgres | mysql
ALPHA7_DB_HOST
ALPHA7_DB_PORT
ALPHA7_DB_USER
ALPHA7_DB_PASSWORD
ALPHA7_DB_NAME
```

### Convenções
- Provider/source string: `'alpha7'` (constante local em cada arquivo, igual ao `'hos'` no HOS)
- Pool: singleton criado uma vez no módulo — injetar como provider customizado com `provide: 'ALPHA7_DB_POOL'`
- Queries prefixam schema: `` `${schema}.out_embalagem` ``
- Sync sequencial por empresa: `for...of` no cron handler (não `Promise.all`)
- `unitCode = 'default'` para estoque Alpha7 (tabela não tem unidade por filial)
- `isActive = !o_inativa` (campo invertido)
- Cursor: ISO datetime armazenado em `company_integrations.sync_cursor`; capturado ANTES da query para não perder deltas
- Comentário só se porquê não-óbvio; sem JSDoc; sem narrar o que o código faz
- Sem i18n: strings pt-BR direto no componente

### Mapa de arquivos relevantes (referência — não modificar nas tasks que não os listam)

**neo-api:**
- `src/modules/hos-integration/` — módulo de referência completo
- `src/modules/hos-integration/clients/hos-api.ts` — padrão de client
- `src/modules/hos-integration/handlers/hos-sync-cron.handler.ts` — padrão de handler
- `src/modules/hos-integration/services/use-cases/sync-hos-catalog.service.ts` — padrão de sync
- `src/modules/hos-integration/services/use-cases/save-hos-credentials.service.ts` — padrão de save
- `src/modules/hos-integration/services/use-cases/get-hos-status.service.ts` — padrão de status
- `src/modules/hos-integration/controllers/hos-integration.controller.ts` — padrão de controller
- `src/modules/hos-integration/hos-integration.module.ts` — padrão de módulo
- `src/modules/hos-integration/repositories/` — repositórios canônicos a reutilizar
- `src/common/cron-jobs/providers/cron-job-definitions.provider.ts` — registro de jobs
- `src/app.module.ts` — registro de módulos

**web:**
- `src/services/Integrations/HOS/index.ts` — padrão de serviço web
- `src/pages/Integrations/pages/HOS/index.tsx` — padrão de página
- `src/pages/Integrations/utils/integrations.ts` — lista de cards
- `src/routes/list.routes.tsx` — rotas de integração

---

## Tasks

### T1 [P] [opus] — Alpha7DbReader (L1)
**Arquivos:**
- Create: `src/modules/alpha7-integration/clients/alpha7-db-reader.ts`
- Create: `src/modules/alpha7-integration/clients/alpha7-db-reader.test.ts`

**Aceitação:**
- `Alpha7DbReader` recebe pool (`'ALPHA7_DB_POOL'` injetado) e expõe dois métodos:
  - `validateConnection(schema: string): Promise<void>` — executa `SELECT 1 FROM {schema}.out_embalagem LIMIT 1`; lança erro descritivo se falhar
  - `fetchChanged(schema: string, cursor: string | null): Promise<OutEmbalagemRow[]>` — sem cursor: `SELECT ... FROM {schema}.out_embalagem`; com cursor: adiciona `WHERE do_estoque > $1 OR do_precovenda > $1 OR do_descricao > $1 OR do_inativa > $1`
- Pool singleton criado como provider Nest com `provide: 'ALPHA7_DB_POOL'`, detectando `ALPHA7_DB_TYPE`:
  - `postgres`: usa `pg.Pool` com `max: 10`
  - `mysql`: usa `mysql2.createPool` com `connectionLimit: 10`
- `OutEmbalagemRow` interface local com todos os campos necessários (`o_ID`, `o_descricao`, `o_codigobarras`, `o_precovenda`, `o_nomeprincipioativo`, `o_apresentacao`, `o_inativa`, `o_estoque`, `o_nomefabricante`, `o_nomeclassificacaoprimeironivel`)
- SELECT explícito somente dos campos acima (não `SELECT *`)

**Testes:**
- `fetchChanged` sem cursor retorna todos os rows (sem WHERE)
- `fetchChanged` com cursor monta WHERE corretamente com o valor do cursor em todas as 4 colunas `do_*`
- `validateConnection` com schema existente resolve sem erro
- `validateConnection` com schema inválido rejeita com mensagem descritiva

---

### T2 [P] [fast] — DTOs e interfaces (L1)
**Arquivos:**
- Create: `src/modules/alpha7-integration/dtos/save-alpha7-credentials.dto.ts`

**Aceitação:**
- `SaveAlpha7CredentialsDto` com campos:
  - `schema: string` — `@IsString()`, `@IsNotEmpty()`
  - `enabled: boolean` — `@IsBoolean()`
- Decoradores `class-validator` idênticos ao padrão HOS (`save-hos-credentials.dto.ts`)

**Testes:**
- DTO aceita `{ schema: 'empresa_x', enabled: true }`
- DTO rejeita `{ schema: '', enabled: true }` (schema vazio)
- DTO rejeita sem campo `enabled`

---

### T3 [P] [fast] — HOS cron: atualizar frequência para */5 * * * * (L1)
**Arquivos:**
- Modify: `src/common/cron-jobs/providers/cron-job-definitions.provider.ts`

**Aceitação:**
- Job `hos-products-sync`: `pattern` muda de `'0 * * * *'` para `'*/5 * * * *'`
- `lock.ttlSeconds` muda de `55 * 60` para `4 * 60` (4 minutos, abaixo da janela de 5min)
- `description` atualizado para refletir o novo intervalo
- Nenhuma outra alteração no arquivo

**Testes:**
- Verificar via grep/leitura que `pattern: '*/5 * * * *'` e `ttlSeconds: 4 * 60` estão presentes

---

### T4 [P] [opus] — SaveAlpha7CredentialsService (L2, depende: T1, T2)
**Arquivos:**
- Create: `src/modules/alpha7-integration/services/use-cases/save-alpha7-credentials.service.ts`
- Create: `src/modules/alpha7-integration/services/use-cases/save-alpha7-credentials.service.test.ts`

**Aceitação:**
- `execute({ companyId, schema, enabled })`:
  1. Chama `alpha7DbReader.validateConnection(schema)` — propaga erro se falhar
  2. Chama `companyIntegrationsRepository.upsert(companyId, 'alpha7', { credentials: { schema }, config: {}, status: enabled ? 'enabled' : 'disabled' })`
- Não persiste se a validação falhar
- Lança `ValidationException` com mensagem clara se schema inválido

**Testes:**
- Sucesso: validateConnection resolve → upsert chamado com credenciais corretas
- Falha: validateConnection rejeita → upsert NÃO chamado, erro propagado
- `enabled: false` → status `'disabled'` no upsert

---

### T5 [P] [opus] — SyncAlpha7CatalogService (L2, depende: T1, T2)
**Arquivos:**
- Create: `src/modules/alpha7-integration/services/use-cases/sync-alpha7-catalog.service.ts`
- Create: `src/modules/alpha7-integration/services/use-cases/sync-alpha7-catalog.service.test.ts`

**Aceitação:**
- `execute({ companyId })`:
  1. Busca `company_integrations WHERE provider='alpha7'` — retorna early se não `'enabled'`
  2. Valida `credentials.schema` presente — lança `ValidationException` se ausente
  3. Captura `syncStartedAt = new Date().toISOString()` antes da query
  4. Detecta `isFullSync = !syncCursor`
  5. Chama `alpha7DbReader.fetchChanged(schema, syncCursor)` → lista de `OutEmbalagemRow`
  6. Filtra rows com `o_ID == null || o_descricao == null`
  7. Mapeia para formato canônico de produtos e estoque:
     - `externalId = String(row.o_ID)`
     - `name = row.o_descricao`
     - `barcode = row.o_codigobarras ?? null`
     - `price = row.o_precovenda != null ? String(row.o_precovenda) : null`
     - `activeIngredient = row.o_nomeprincipioativo ?? null`
     - `unit = row.o_apresentacao ?? null`
     - `isActive = !row.o_inativa`
     - `metadata = { nomefabricante: row.o_nomefabricante, classificacao: row.o_nomeclassificacaoprimeironivel }`
     - Stock: `{ externalId: String(row.o_ID), unitCode: 'default', stock: String(row.o_estoque) }`
  8. `productsRepo.upsertMany(companyId, 'alpha7', produtos)`
  9. `stockRepo.upsertMany(companyId, 'alpha7', estoques)`
  10. Se `isFullSync && externalIds.length > 0`: `productsRepo.markInactiveNotIn(companyId, 'alpha7', externalIds)`
  11. Se `isFullSync && externalIds.length === 0`: log warn, skip markInactiveNotIn
  12. `integrationsRepo.updateSyncState(companyId, 'alpha7', { lastSyncedAt: syncStartedAt, syncCursor: syncStartedAt })`

**Testes:**
- Full sync (sem cursor): fetchChanged chamado com `null`, markInactiveNotIn chamado com externalIds corretos
- Incremental (com cursor): fetchChanged chamado com cursor, markInactiveNotIn NÃO chamado
- Full sync com lista vazia: markInactiveNotIn NÃO chamado (guard)
- Row com `o_inativa = true` → `isActive = false`
- Row com `o_ID = null` → filtrado
- syncCursor atualizado para syncStartedAt após sucesso

---

### T6 [P] [fast] — GetAlpha7StatusService (L2, depende: T1, T2)
**Arquivos:**
- Create: `src/modules/alpha7-integration/services/use-cases/get-alpha7-status.service.ts`
- Create: `src/modules/alpha7-integration/services/use-cases/get-alpha7-status.service.test.ts`

**Aceitação:**
- `execute(companyId)` retorna `{ status, lastSyncedAt, hasCredentials, schema }`:
  - Sem integração cadastrada: `{ status: 'disabled', lastSyncedAt: null, hasCredentials: false, schema: null }`
  - Com integração: lê `status`, `lastSyncedAt`, `credentials.schema`
  - `hasCredentials = !!credentials?.schema`

**Testes:**
- Sem integração: retorna objeto com todos os nulls e status disabled
- Com integração habilitada: retorna status, lastSyncedAt e schema corretos
- `hasCredentials = false` quando schema ausente nas credentials

---

### T7 [P] [fast] — Alpha7IntegrationController (L3, depende: T4, T5, T6)
**Arquivos:**
- Create: `src/modules/alpha7-integration/controllers/alpha7-integration.controller.ts`
- Create: `src/modules/alpha7-integration/controllers/alpha7-integration.controller.test.ts`

**Aceitação:**
- Espelha `HosIntegrationController` com `@Controller('integrations/alpha7')` e `@ApiTags('Alpha7 Integration')`
- `GET /integrations/alpha7` → `GetAlpha7StatusService.execute(user.company_id)`
- `POST /integrations/alpha7` body `{ schema, enabled }` → `SaveAlpha7CredentialsService.execute({ companyId, schema, enabled })`
- `POST /integrations/alpha7/sync` → enfileira job `'alpha7-products-sync'` com `{ companyId }` via `CronJobQueueService`
- Usa `BaseController.ok()` e `BaseController.handleError()` igual ao HOS

**Testes:**
- GET retorna output do status service
- POST chama save service com params corretos
- POST /sync enfileira job com companyId correto
- Erro no service → handleError chamado

---

### T8 [P] [fast] — Alpha7SyncCronHandler + registro do job (L3, depende: T4, T5, T6)
**Arquivos:**
- Create: `src/modules/alpha7-integration/handlers/alpha7-sync-cron.handler.ts`
- Create: `src/modules/alpha7-integration/handlers/alpha7-sync-cron.handler.test.ts`
- Modify: `src/common/cron-jobs/providers/cron-job-definitions.provider.ts`

**Aceitação:**
- Handler `@CronJobHandler('alpha7-products-sync')`:
  - Com `payload.companyId`: executa `syncService.execute({ companyId })` para empresa específica
  - Sem `payload.companyId`: busca todas as `company_integrations` com `provider='alpha7'` e `status='enabled'`, itera **sequencialmente** com `for...of`, captura erro por empresa sem interromper o loop
- Job registrado em `cron-job-definitions.provider.ts`:
  - `name: 'alpha7-products-sync'`
  - `pattern: '*/5 * * * *'`
  - `lock: { enabled: true, ttlSeconds: 4 * 60, skipWhenLocked: true }`
  - `attempts: 1`, `removeOnComplete: 10`, `removeOnFail: 10`

**Testes:**
- Com `payload.companyId`: sync service chamado uma vez para a empresa
- Sem payload: sync service chamado para cada empresa habilitada em sequência
- Erro numa empresa: log de erro, demais empresas continuam sendo processadas

---

### T9 [fast] — Alpha7IntegrationModule + registro no AppModule (L4, depende: T7, T8)
**Arquivos:**
- Create: `src/modules/alpha7-integration/alpha7-integration.module.ts`
- Modify: `src/app.module.ts`

**Aceitação:**
- `Alpha7IntegrationModule` declara providers: `Alpha7DbReader`, pool provider `'ALPHA7_DB_POOL'`, `CompanyIntegrationsRepository`, `IntegrationProductsRepository`, `IntegrationProductStockRepository`, `SaveAlpha7CredentialsService`, `SyncAlpha7CatalogService`, `GetAlpha7StatusService`, `Alpha7SyncCronHandler`
- Controller: `Alpha7IntegrationController`
- `AppModule` importa `Alpha7IntegrationModule` (após `HosIntegrationModule`)
- `pnpm build` passa sem erro de TypeScript

**Testes:**
- `pnpm build` sem erros
- `pnpm lint` sem erros

---

### T10 [P] [fast] — Web: serviço + entry + rota (L5, depende: T9)
**Arquivos:**
- Create: `src/services/Integrations/Alpha7/index.ts`
- Create: `src/pages/Integrations/assets/alpha7-logo.png` ← usar hos-logo.jpeg como placeholder (copiar); anotar no arquivo um comentário no topo do index.tsx que logo real deve ser substituída
- Modify: `src/pages/Integrations/utils/integrations.ts`
- Modify: `src/routes/list.routes.tsx`

**Aceitação:**
- Serviço expõe: `getAlpha7Config()`, `updateAlpha7()`, `syncAlpha7()` (espelha HOS)
- Interface `Alpha7ConfigResponse`: `{ status, lastSyncedAt, hasCredentials, schema }`
- Interface `Alpha7UpdateRequest`: `{ schema: string, enabled: boolean }`
- `integrations.ts`: entry `{ id: 10, name: 'Alpha7', logo: Alpha7Logo, url: 'alpha7' }` inserida **entre HOS (id 9) e NAPP (id 7)** no array
- Rota `/integrations/alpha7` registrada em `list.routes.tsx` com lazy import do componente `Alpha7`

**Testes:**
- `getAlpha7Config` faz GET `/integrations/alpha7` e retorna dados tipados
- `updateAlpha7` faz POST `/integrations/alpha7` com `{ schema, enabled }`
- `syncAlpha7` faz POST `/integrations/alpha7/sync`

---

### T11 [P] [opus] — Web: página Alpha7/index.tsx (L5, depende: T9)
**Arquivos:**
- Create: `src/pages/Integrations/pages/Alpha7/index.tsx`
- Create: `src/pages/Integrations/pages/Alpha7/styles.ts` (reutilizar styled-components do HOS)

**Aceitação:**
- Formulário com campo único `schema` (string, obrigatório se `enabled = true`) + toggle `enabled`
- Validação com `zod` + `react-hook-form` (igual ao HOS): schema obrigatório quando enabled
- Ao montar: carrega config via `getAlpha7Config()` e preenche o form
- Botão "Salvar": chama `updateAlpha7({ schema, enabled })`, exibe toast de sucesso/erro
- Botão "Sincronizar agora": chama `syncAlpha7()`, exibe toast
- Exibe `lastSyncedAt` formatado se disponível
- Botão voltar via `navigate(-1)`

**Testes:**
- Renderiza form com campo schema e toggle
- Submit com enabled=true e schema vazio → erro de validação, sem chamar updateAlpha7
- Submit válido → updateAlpha7 chamado com { schema, enabled }
- Erro da API → toast de erro exibido

---

## Self-review

1. **Cobertura:** pool (T1), DTOs (T2), HOS cron fix (T3), save/sync/status (T4/T5/T6), controller (T7), cron handler + job (T8), módulo (T9), web service + entry (T10), web page (T11). Todos os requisitos do spec cobertos.
2. **Disjunção L1:** T1 (alpha7-db-reader.ts), T2 (dtos/), T3 (cron-job-definitions.provider.ts) — arquivos disjuntos ✓
3. **Disjunção L2:** T4 (save-alpha7-credentials.service.ts), T5 (sync-alpha7-catalog.service.ts), T6 (get-alpha7-status.service.ts) — disjuntos ✓
4. **Disjunção L3:** T7 (controller.ts), T8 (cron.handler.ts + cron-job-definitions.provider.ts) — T3 já modificou cron-job-definitions em L1, T8 o modifica de novo em L3 (adiciona entry nova) — sem conflito intra-camada pois estão em camadas diferentes ✓
5. **Disjunção L5:** T10 (services/Alpha7/, integrations.ts, list.routes.tsx), T11 (pages/Alpha7/) — disjuntos ✓
6. **DAG:** L1→L2→L3→L4→L5 sem ciclos ✓
7. **Tiers:** T1 (pool dual-driver, query dinâmica) e T4/T5 (lógica de sync/save) promovidos a `[opus]`; T11 (página multi-estado) promovida a `[opus]` ✓
8. **Verificabilidade:** todas as aceitações têm testes nomeados ✓
