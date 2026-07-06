---
name: monday-api
description: Use when making ANY change to Monday.com (create/update/move/archive/delete items, set column values, change status/people/date, post updates or comments) or reading board/item/group data via the Monday API. The single mandatory gateway for every Monday.com operation in this base.
---

# monday-api

## Overview

All skill operation, examples, prompts, and user-facing responses must be in English.

**Single gateway for ALL Monday.com operations.** Every Monday read or write
(items, columns, statuses, groups, updates/comments) MUST go through this skill
and the `monday.sh` helper. This keeps one token source, one API version, and one
audit/confirmation point for destructive operations.

Authentication uses the **environment variable** `MONDAY_API_TOKEN` — **never**
embed the token in code, prompts, or git.

## Golden rule (discipline)

- **No Monday calls outside this skill.** Do not build ad-hoc `curl`/`fetch` calls
  to `api.monday.com` with any other token source. Use `monday.sh`.
- **Token only through `MONDAY_API_TOKEN`.** If it is not set, **stop and ask** the
  user to export it — do not invent it, search for it in files, or hardcode it.
- **Destructive operations require explicit user confirmation** before running:
  `delete_item`, `archive_item`, `delete_group`, `delete_update`, any bulk
  `change_*`. Show what will change and wait for "ok".
- Violating the letter of this rule violates its spirit.

## Setup (uma vez por shell)

```bash
export MONDAY_API_TOKEN="<your Monday API token>"   # Monday → Avatar → Developers → My access tokens
# optional: export MONDAY_API_VERSION="2024-10"
```

Requires `curl` and `jq` in PATH.

## Usage

`monday.sh` receives a GraphQL query/mutation and an optional variables JSON, then
returns the API JSON response:

```bash
./monday.sh '<graphql>' '<variables-json>'
```

## Quick reference (common operations)

| Intent | GraphQL |
|---|---|
| Read a board (groups + columns) | `query{ boards(ids:[BOARD_ID]){ name groups{id title} columns{id title type} } }` |
| List items (paginated) | `query{ boards(ids:[BOARD_ID]){ items_page(limit:50){ cursor items{id name} } } }` |
| Create item | `mutation($b:ID!,$g:String!,$n:String!,$v:JSON!){ create_item(board_id:$b,group_id:$g,item_name:$n,column_values:$v){id} }` |
| Change item columns | `mutation($b:ID!,$i:ID!,$v:JSON!){ change_multiple_column_values(board_id:$b,item_id:$i,column_values:$v){id} }` |
| Move item to group | `mutation($i:ID!,$g:String!){ move_item_to_group(item_id:$i,group_id:$g){id} }` |
| Post update/comment | `mutation($i:ID!,$t:String!){ create_update(item_id:$i,body:$t){id} }` |
| Archive item (destructive) | `mutation($i:ID!){ archive_item(item_id:$i){id} }` |
| Delete item (destructive) | `mutation($i:ID!){ delete_item(item_id:$i){id} }` |

Example — create an item with status and date through variables (without
interpolating values into the query):

```bash
./monday.sh \
  'mutation($b:ID!,$g:String!,$n:String!,$v:JSON!){ create_item(board_id:$b,group_id:$g,item_name:$n,column_values:$v){id} }' \
  '{"b":"123456","g":"topics","n":"New card","v":"{\"status\":{\"label\":\"Working on it\"},\"date4\":{\"date\":\"2026-06-10\"}}"}'
```

> `column_values` is a **JSON string** inside the variables JSON (note the escaping).
> Column IDs (`status`, `date4`, …) and `group_id` come from the board — read the
> board first if you do not know them.

## Common mistakes

- **Interpolating values directly in the query string** → breaks on quotes/accents
  and opens injection risk. Always pass data through the 2nd argument (GraphQL variables).
- **Errors arrive with HTTP 200**: Monday returns `{"errors":[...]}` with status
  200. Always check the `errors` field in the response (the helper prints raw JSON).
- **`column_values` as an object** instead of a JSON string → the API rejects it.
  It must be an escaped JSON string.
- **Running destructive operations without confirmation** → stop and ask for ok first.
- **Missing token** → `monday.sh` fails with clear instructions; export
  `MONDAY_API_TOKEN`, do not bypass it.

## Implementation

Reusable gateway: [`monday.sh`](./monday.sh) — reads `MONDAY_API_TOKEN`, POSTs to
`https://api.monday.com/v2`, builds `{query,variables}` with `jq`, and prints the
response. It is the only authorized point for talking to Monday.
