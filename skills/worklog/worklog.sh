#!/usr/bin/env bash
# worklog.sh — mechanical IO for the WorkLog vault (AI-directed work journal).
#
# Does only deterministic mechanical work: call overview-do-dia (read-only on
# Monday), collect day commits in worktrees, and ensure the daily skeleton.
# PROSE (daily/frentes/impedimentos/retro synthesis) is written by the AI following
# the vault AGENTS.md — NOT by this script.
#
# Usage:
#   ./worklog.sh paths                 # shows resolved paths + today's date
#   ./worklog.sh ensure-daily [DATA]   # creates daily/<DATA>.md (skeleton) if missing
#   ./worklog.sh abrir [MODO] [DATA]   # overview -> raw/<DATA>/monday.json + daily
#   ./worklog.sh git-dia [DATA]        # author's day commits -> raw/<DATA>/git.md
#   ./worklog.sh fechar [MODO] [DATA]  # abrir(MODO|fim) + git-dia together
#
# MODO: inicio | meio | fim   (default: lets overview infer by time)
# DATA: YYYY-MM-DD            (default: today)
#
# Requires: jq, git, and (for abrir/fechar) exported MONDAY_API_TOKEN.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$SCRIPT_DIR/config.json"
[ -f "$CONFIG" ] || { echo "worklog.sh: config.json not found in $SCRIPT_DIR" >&2; exit 1; }
command -v jq >/dev/null || { echo "worklog.sh: jq is required in PATH" >&2; exit 1; }

cfg() { jq -r "$1" "$CONFIG"; }
expand_tilde() { case "$1" in "~"|"~/"*) printf '%s\n' "${HOME}${1#\~}";; *) printf '%s\n' "$1";; esac; }

VAULT="$(expand_tilde "$(cfg '.vault_path')")"
GIT_AUTHOR="$(cfg '.git_author')"
OVERVIEW="$SCRIPT_DIR/$(cfg '.overview_script')"

today() { date +%Y-%m-%d; }

weekday_en() {
  case "$(date -d "$1" +%u 2>/dev/null || date +%u)" in
    1) echo "Monday";; 2) echo "Tuesday";; 3) echo "Wednesday";; 4) echo "Thursday";;
    5) echo "Friday";; 6) echo "Saturday";; 7) echo "Sunday";; *) echo "";;
  esac
}

daylabel_en() {
  local d="$1" dd mm
  dd="$(date -d "$d" +%d 2>/dev/null || echo "$d")"
  case "$(date -d "$d" +%m 2>/dev/null)" in
    01) mm="Jan";; 02) mm="Feb";; 03) mm="Mar";; 04) mm="Apr";;
    05) mm="May";; 06) mm="Jun";; 07) mm="Jul";; 08) mm="Aug";;
    09) mm="Sep";; 10) mm="Oct";; 11) mm="Nov";; 12) mm="Dec";; *) mm="";;
  esac
  printf '%s %s · %s' "$dd" "$mm" "$(weekday_en "$d")"
}

ensure_vault() {
  [ -d "$VAULT" ] || { echo "worklog.sh: vault not found at $VAULT (see config.json)" >&2; exit 1; }
  mkdir -p "$VAULT/raw" "$VAULT/daily" "$VAULT/frentes" "$VAULT/impedimentos" "$VAULT/retro"
}

ensure_daily() {
  local d="${1:-$(today)}"
  ensure_vault
  local f="$VAULT/daily/$d.md"
  if [ -f "$f" ]; then echo "$f (already exists)"; return 0; fi
  local label; label="$(daylabel_en "$d")"
  cat > "$f" <<EOF
---
type: daily
data: $d
tags: [daily]
---

# 📅 $label

> [!abstract] Day summary
> _(N items · N overdue · focus on …)_

## 📋 Plan

## ✅ Done

## 🚧 Blockers

## 💡 Decisions / Learnings

---

### 🗣️ For tomorrow's daily
EOF
  echo "$f (created)"
}

abrir() {
  local modo="${1:-}" d="${2:-$(today)}"
  ensure_vault
  [ -x "$OVERVIEW" ] || { echo "worklog.sh: overview.sh not found/executable: $OVERVIEW" >&2; exit 1; }
  mkdir -p "$VAULT/raw/$d"
  local out="$VAULT/raw/$d/monday.json"
  echo "-> running overview-do-dia ${modo:-(automatic mode)}..." >&2
  if [ -n "$modo" ]; then "$OVERVIEW" "$modo" > "$out"; else "$OVERVIEW" > "$out"; fi
  echo "snapshot saved: $out" >&2
  ensure_daily "$d" >&2
  cat "$out"
}

git_dia() {
  local d="${1:-$(today)}"
  ensure_vault
  mkdir -p "$VAULT/raw/$d"
  local out="$VAULT/raw/$d/git.md"
  local since="$d 00:00:00" until="$d 23:59:59"
  {
    echo "# Commits for $d — author: $GIT_AUTHOR"
    echo
    local repos; repos="$(cfg '.repos[]')"
    while IFS= read -r repo; do
      [ -d "$repo/.git" ] || [ -f "$repo/.git" ] || { continue; }
      local wt branch
      while IFS= read -r line; do
        case "$line" in
          worktree\ *) wt="${line#worktree }";;
          branch\ *) branch="${line#branch refs/heads/}";;
          "")
            if [ -n "${wt:-}" ] && [ -d "$wt" ]; then
              local log
              log="$(git -C "$wt" log --no-merges --since="$since" --until="$until" \
                     --author="$GIT_AUTHOR" --pretty='- %h %s' 2>/dev/null || true)"
              if [ -n "$log" ]; then
                echo "## $(basename "$wt") [${branch:-?}]"
                echo "$log"
                echo
              fi
            fi
            wt=""; branch=""
            ;;
        esac
      done < <(git -C "$repo" worktree list --porcelain 2>/dev/null; echo)
    done <<< "$repos"
  } > "$out"
  echo "day git saved: $out" >&2
  cat "$out"
}

fechar() {
  local modo="${1:-fim}" d="${2:-$(today)}"
  abrir "$modo" "$d" >/dev/null
  echo "---" >&2
  git_dia "$d"
}

cmd="${1:-paths}"; shift || true
case "$cmd" in
  paths)
    echo "vault:    $VAULT"
    echo "overview: $OVERVIEW"
    echo "autor:    $GIT_AUTHOR"
    echo "today:    $(today) ($(weekday_en "$(today)"))"
    ;;
  ensure-daily) ensure_daily "${1:-}";;
  abrir)        abrir "${1:-}" "${2:-}";;
  git-dia)      git_dia "${1:-}";;
  fechar)       fechar "${1:-}" "${2:-}";;
  *) echo "worklog.sh: unknown subcommand '$cmd' (use: paths|ensure-daily|abrir|git-dia|fechar)" >&2; exit 1;;
esac
