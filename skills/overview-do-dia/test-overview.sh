#!/usr/bin/env bash
#
# test-overview.sh — tests overview.sh classification with a fixture (no network).
# Run: ./test-overview.sh
#
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURE="$SCRIPT_DIR/references/fixture-items.json"

OUT="$("$SCRIPT_DIR/overview.sh" --classify < "$FIXTURE")"

fail=0
check() { # $1 description  $2 jq-filter (must be true)
  if printf '%s' "$OUT" | jq -e "$2" >/dev/null; then
    echo "  ok   - $1"
  else
    echo "  FAIL - $1"; fail=1
  fi
}

echo "test-overview (classification):"
check "total = 6 (completed excluded)"          '.counts.total == 6'
check "1 overdue"                               '.counts.atrasados == 1'
check "overdue is A (QA failed it, expired)"    '.buckets.atrasados | map(.id) == ["A"]'
check "teste_reprovado = [F]"                   '.buckets.teste_reprovado | map(.id) == ["F"]'
check "code_review = [B]"                       '.buckets.code_review | map(.id) == ["B"]'
check "em_andamento = [C]"                      '.buckets.em_andamento | map(.id) == ["C"]'
check "a_fazer sorted = [D, G]"                 '.buckets.a_fazer | map(.id) == ["D","G"]'
check "unknown status falls into a_fazer"       '.buckets.a_fazer | map(.id) | index("G") != null'
check "completed (E) does not appear"           '[.buckets[][].id] | index("E") == null'
check "A marked overdue"                        '.buckets.atrasados[0].overdue == true'

if [ "$fail" -ne 0 ]; then echo "FAILED"; exit 1; fi
echo "all tests passed"
