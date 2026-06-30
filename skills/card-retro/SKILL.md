---
name: card-retro
description: Use ao FINALIZAR uma frente/card para registrar uma retrospectiva curta no vault Second Brain — gatilhos "registra a retro", "card-retro", "documenta a frente no second brain", "fecha o card no second brain". Garante (guard) que o README da task esteja atualizado, PEDE o link do card e as datas, e escreve daily-notes/<AAAA-MM>/<AAAA-MM-DD>-<slug>.md respondendo: o que fizemos, por quê, que problema resolve, pontas soltas e o que poderia ter sido feito melhor.
---

# card-retro

## Overview

Registra a **retrospectiva de uma frente/card** no vault **Second Brain**
(`~/Documents/Second Brain/daily-notes/<AAAA-MM>/`), um arquivo por card, com
template **minimalista**. As respostas são **sintetizadas pela IA** a partir do
trabalho feito na sessão; o **link do card e as datas são pedidos ao usuário** (nunca
inventados).

A skill **vive no repo helix** (`skills/card-retro/`); o arquivo gerado mora **no
vault** e **não** entra no git do helix.

## Regra de ouro

1. **GUARD — README da task primeiro.** Antes de escrever a retro, o README do
   módulo/repo tocado na frente **DEVE** refletir o que foi alterado. Se estiver
   defasado, atualize-o antes de prosseguir. Sem README em dia, **não registre a retro**.
2. **SEMPRE peça ao usuário** o link do card no Monday, a data de início e a data
   de conclusão. **Nunca invente** essas três informações.
3. **Template minimalista** — não adicione seções, frontmatter ou enfeites além do
   `references/template.md`. Respostas curtas e diretas.

## Procedimento

### 0. Guard — README da task atualizado (BLOQUEANTE)

Identifique o(s) README(s) do(s) módulo(s)/repo(s) alterados na frente (ex.:
`src/modules/<x>/README.md` no repo tocado). Confira se já descrevem **o contexto
atual do que foi alterado** nesta frente. Se **não** descrevem, atualize-os agora
(mesmo estilo do documento existente, conciso). Só avance quando o README refletir a
mudança. Se não houver README aplicável, declare isso e siga.

### 1. Coletar do usuário (obrigatório)

Pergunte e **aguarde** as três respostas (não prossiga sem elas):

- **Link do card** no Monday.
- **Data de início** (`AAAA-MM-DD`).
- **Data de conclusão** (`AAAA-MM-DD`).

### 2. Enriquecer pelo Monday (degradável)

Extraia o `pulse id` do link e, via skill **monday-api**, busque **título** e
**status** do card. Se a chamada falhar ou não houver token, **degrade**: use só o
link e siga (status/título ficam vazios).

### 3. Derivar nome e destino

- `slug`: kebab-case do título do card (ou do nome da frente, se sem título).
- `mês`: `AAAA-MM` da **data de conclusão**.
- Pasta: `~/Documents/Second Brain/daily-notes/<AAAA-MM>/` (crie se não existir).
- Arquivo: `<AAAA-MM-DD-conclusão>-<slug>.md`.

### 4. Escrever a retro

Preencha `references/template.md` com o link, as datas, o status (se houver) e as
**respostas sintetizadas da sessão** para as cinco perguntas:

1. **O que fizemos**
2. **Por que fizemos**
3. **Que problema resolve**
4. **Pontas soltas** (o que ficou em aberto / não tratado)
5. **O que poderia ter sido feito melhor**

Respostas curtas e honestas — sem inflar. Se uma pergunta não tiver resposta real,
diga isso em vez de inventar.

### 5. Confirmar

Informe o caminho do arquivo criado. **Não** commite o arquivo do vault no repo helix.
