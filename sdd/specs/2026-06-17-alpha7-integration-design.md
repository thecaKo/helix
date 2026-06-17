# Alpha7 Integration — Design

**Data:** 2026-06-17
**Frente:** feat-alpha7-integration
**Repos:** neo-api-pharmachatbot, web-pharmachatbot
**Dependência:** feat/hos-integration deve mergiar antes (ou junto)

---

## Contexto

A Alpha7 Software disponibiliza um banco de dados intermediário (MySQL ou PostgreSQL) onde escreve dados de catálogo e estoque da farmácia. Um sistema integrador lê esse banco periodicamente e sincroniza os dados para seu próprio sistema.

Nossa integração lê a tabela `out_embalagem` do banco intermediário da Alpha7 e sincroniza produtos e estoque nas tabelas canônicas já existentes (`integration_products`, `integration_product_stock`) com `source='alpha7'`, reutilizando a infraestrutura criada pela integração HOS.

---

## Decisões de design

### Estratégia de sync
**Cursor timestamp (read-only).** O cron lê o banco intermediário da Alpha7 sem escrever de volta (`io_integracaoConcluida` não é usado). O cursor é um datetime salvo em `company_integrations.sync_cursor`. A cada rodada, a query filtra por `do_estoque > cursor OR do_precovenda > cursor OR do_descricao > cursor OR do_inativa > cursor`. Primeiro run (sem cursor) = full sync de todos os produtos + `markInactiveNotIn`.

### Credenciais e multi-tenancy
O banco intermediário é compartilhado por todas as empresas via schemas (Postgres) ou databases prefixadas (MySQL). A conexão base (host/porta/usuário/senha) fica em **env vars** compartilhadas. Cada empresa armazena apenas `{ schema: string }` em `company_integrations.credentials`.

```
Env vars:
  ALPHA7_DB_TYPE     = postgres | mysql
  ALPHA7_DB_HOST
  ALPHA7_DB_PORT
  ALPHA7_DB_USER
  ALPHA7_DB_PASSWORD
  ALPHA7_DB_NAME
```

### Pool de conexões
Um único pool de **10 conexões** compartilhado por todas as empresas (singleton no módulo). Queries prefixam o schema: `{schema}.out_embalagem`. Empresas são sincronizadas **sequencialmente** (for...of) para não saturar o pool.

### Frequência do cron
`*/5 * * * *` (a cada 5 minutos). Padrão unificado para todas as integrações — o job HOS (`hos-products-sync`) deve ser atualizado para o mesmo intervalo se estiver diferente.

---

## Arquitetura — neo-api

```
src/modules/alpha7-integration/
  clients/
    alpha7-db-reader.ts          ← pool singleton + query com schema dinâmico
  dtos/
    save-alpha7-credentials.dto.ts   ← { schema: string, enabled: boolean }
  handlers/
    alpha7-sync-cron.handler.ts  ← job alpha7-products-sync, */5 * * * *
  services/use-cases/
    save-alpha7-credentials.service.ts
    sync-alpha7-catalog.service.ts
    get-alpha7-status.service.ts
  controllers/
    alpha7-integration.controller.ts
  alpha7-integration.module.ts
```

**Repositórios reutilizados do HOS (sem copiar):**
- `CompanyIntegrationsRepository`
- `IntegrationProductsRepository`
- `IntegrationProductStockRepository`

**Nenhuma alteração de schema Drizzle** — as tabelas canônicas já existem.

---

## Mapeamento de campos

### `out_embalagem` → `integration_products` (`source='alpha7'`)

| `out_embalagem` | Campo canônico | Observação |
|---|---|---|
| `o_ID` | `externalId` | bigint → string |
| `o_descricao` | `name` | varchar(100) |
| `o_codigobarras` | `barcode` | varchar(14) |
| `o_precovenda` | `price` | numeric(15,4) |
| `o_nomeprincipioativo` | `activeIngredient` | varchar(255) |
| `o_apresentacao` | `unit` | varchar(39) |
| `o_inativa` | `isActive` | `!o_inativa` |
| `o_nomefabricante`, `o_nomeclassificacaoprimeironivel`… | `metadata` | JSON |

### `out_embalagem` → `integration_product_stock` (`source='alpha7'`)

| `out_embalagem` | Campo canônico | Observação |
|---|---|---|
| `o_ID` | `externalId` | bigint → string |
| `o_estoque` | `stock` | numeric(15,4) |
| — | `unitCode` | constante `'default'` |

---

## Query incremental

```sql
SELECT o_ID, o_descricao, o_codigobarras, o_precovenda,
       o_nomeprincipioativo, o_apresentacao, o_inativa,
       o_estoque, o_nomefabricante,
       o_nomeclassificacaoprimeironivel
FROM {schema}.out_embalagem
WHERE do_estoque > :cursor
   OR do_precovenda > :cursor
   OR do_descricao > :cursor
   OR do_inativa > :cursor
```

Full sync (cursor null): sem cláusula WHERE.

---

## Fluxo do cron

1. Busca `company_integrations WHERE provider='alpha7' AND status='enabled'`
2. `for...of` sequencial por empresa:
   - Captura `syncStartedAt` antes da query
   - Detecta full sync (`!syncCursor`)
   - Executa query incremental ou full no banco intermediário
   - Mapeia rows para formato canônico
   - `productsRepo.upsertMany(companyId, 'alpha7', produtos)`
   - `stockRepo.upsertMany(companyId, 'alpha7', estoques)`
   - Se full sync: `productsRepo.markInactiveNotIn(companyId, 'alpha7', externalIds)`
   - `integrationsRepo.updateSyncState(companyId, 'alpha7', { lastSyncedAt: syncStartedAt, syncCursor: syncStartedAt })`
   - Erro por empresa: log + continua loop (não interrompe as demais)

---

## Controller

```
GET  /integrations/alpha7        → status { status, lastSyncedAt, productCount }
POST /integrations/alpha7        → salva credenciais { schema, enabled }
                                   valida: SELECT 1 FROM {schema}.out_embalagem LIMIT 1
POST /integrations/alpha7/sync   → sync manual
```

---

## Validação de credencial

`SaveAlpha7CredentialsService` testa a conexão antes de salvar: executa `SELECT 1 FROM {schema}.out_embalagem LIMIT 1` usando o pool compartilhado. Se falhar (schema inexistente, permissão negada, tabela ausente), lança `ValidationException` com mensagem descritiva. Só persiste se o teste passar.

---

## Arquitetura — web

```
src/pages/Integrations/
  assets/alpha7-logo.png
  pages/Alpha7/index.tsx          ← campo "Schema", toggle enabled, botão salvar
                                     card de status (último sync, total produtos)
  services/Integrations/Alpha7/index.ts
  utils/integrations.ts           ← id 10, posição entre HOS (id 9) e NAPP (id 7)
  routes/list.routes.tsx          ← rota /integrations/alpha7
```

Formulário: campo único `schema` (nome do schema no banco intermediário) + toggle enabled/disabled. Botão salvar valida a conexão via POST antes de persistir.

---

## Error handling

- Falha de conexão ao banco intermediário: log de erro, empresa skipada, cron continua
- Schema inexistente ou sem permissão: `ValidationException` no save de credenciais
- Produto sem `o_ID` ou `o_descricao`: filtrado antes do upsert (igual ao HOS)
- Full sync com lista vazia: `markInactiveNotIn` ignorado para evitar deleção indevida (mesmo guard do HOS)

---

## Testes

- `Alpha7DbReader`: mock do pool, verifica query com schema correto
- `SaveAlpha7CredentialsService`: mock do reader, testa falha de validação e sucesso
- `SyncAlpha7CatalogService`: mock do reader + repositórios, verifica full sync vs incremental, cursor atualizado
- `Alpha7SyncCronHandler`: verifica iteração sequencial e isolamento de erro por empresa
- `Alpha7IntegrationController`: testes de contrato dos 3 endpoints
