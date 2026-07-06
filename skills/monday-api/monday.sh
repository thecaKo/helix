#!/usr/bin/env bash
#
# monday.sh — single gateway for the Monday.com API (skill: monday-api).
# Every Monday call goes through this file. Token only via MONDAY_API_TOKEN.
#
# Usage:
#   ./monday.sh '<graphql query|mutation>' '[variables-json]'
#
# Ex.:
#   ./monday.sh 'query{ boards(ids:[123]){ name } }'
#   ./monday.sh 'mutation($n:String!){ create_item(board_id:123,item_name:$n){id} }' '{"n":"hello"}'
#
set -euo pipefail

: "${MONDAY_API_TOKEN:?Set the token before use:  export MONDAY_API_TOKEN=...  (Monday > Developers > My access tokens)}"

API_URL="https://api.monday.com/v2"
API_VERSION="${MONDAY_API_VERSION:-2024-10}"

QUERY="${1:?usage: monday.sh '<graphql>' '[variables-json]'}"
if [ "$#" -ge 2 ] && [ -n "$2" ]; then VARIABLES="$2"; else VARIABLES='{}'; fi

command -v jq   >/dev/null 2>&1 || { echo "monday.sh: requires 'jq' in PATH" >&2; exit 127; }
command -v curl >/dev/null 2>&1 || { echo "monday.sh: requires 'curl' in PATH" >&2; exit 127; }

PAYLOAD="$(jq -n --arg q "$QUERY" --argjson v "$VARIABLES" '{query:$q, variables:$v}')"

RESPONSE="$(
  curl -sS -X POST "$API_URL" \
    -H "Authorization: $MONDAY_API_TOKEN" \
    -H "Content-Type: application/json" \
    -H "API-Version: $API_VERSION" \
    --data "$PAYLOAD"
)"

echo "$RESPONSE" | jq .

if echo "$RESPONSE" | jq -e '.errors // empty | length > 0' >/dev/null 2>&1; then
  echo "monday.sh: the API returned errors (see above)." >&2
  exit 1
fi
