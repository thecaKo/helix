#!/usr/bin/env bash
# test-worklog.sh — validates worklog.sh mechanical IO WITHOUT touching real Monday/git.
# Creates a temporary vault + temporary config and exercises ensure-daily.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

VAULT="$TMP/vault"
mkdir -p "$VAULT"

# temporary config pointing to the temporary vault
CFG="$TMP/config.json"
cat > "$CFG" <<EOF
{
  "vault_path": "$VAULT",
  "git_author": "nobody",
  "overview_script": "../overview-do-dia/overview.sh",
  "repos": []
}
EOF

# runs worklog.sh with the temporary config (through a copy that uses tmp CFG)
run() { ( cd "$SCRIPT_DIR" && CONFIG_OVERRIDE="$CFG" bash -c '
    SCRIPT_DIR="'"$SCRIPT_DIR"'"
    sed "s#CONFIG=\"\$SCRIPT_DIR/config.json\"#CONFIG=\"$CONFIG_OVERRIDE\"#" "$SCRIPT_DIR/worklog.sh" > "'"$TMP"'/wl.sh"
    bash "'"$TMP"'/wl.sh" "$@"
  ' _ "$@" ); }

fail() { echo "FAILED: $1" >&2; exit 1; }

# 1) ensure-daily creates the file with 5 sections (minimal elegant layout)
run ensure-daily 2026-06-09 >/dev/null
F="$VAULT/daily/2026-06-09.md"
[ -f "$F" ] || fail "daily was not created"
for sec in "## 📋 Plan" "## ✅ Done" "## 🚧 Blockers" "## 💡 Decisions / Learnings" "### 🗣️ For tomorrow's daily"; do
  grep -qF "$sec" "$F" || fail "missing section: $sec"
done
grep -qF "# 📅 09 Jun · Tuesday" "$F" || fail "wrong readable date/header"
grep -qF "tags: [daily]" "$F" || fail "frontmatter missing tags"
grep -qF "> [!abstract] Day summary" "$F" || fail "missing summary callout"

# 2) idempotence: running again does not duplicate or erase
before="$(md5sum "$F" | cut -d' ' -f1)"
out="$(run ensure-daily 2026-06-09)"
after="$(md5sum "$F" | cut -d' ' -f1)"
[ "$before" = "$after" ] || fail "ensure-daily is not idempotent"
echo "$out" | grep -q "already exists" || fail "did not signal 'already exists'"

# 3) paths resolves the vault
paths_out="$(run paths)"
echo "$paths_out" | grep -q '^vault:' || fail "paths did not print 'vault:' line"
echo "$paths_out" | grep -qF "$VAULT" || fail "paths did not resolve the vault ($VAULT)"

echo "OK - all tests passed"
