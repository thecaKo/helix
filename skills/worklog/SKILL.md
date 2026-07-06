---
name: worklog
description: Use when the user wants to record/organize the day's work in the WorkLog vault (AI-directed journal) to feed daily and retro — "open the day", "record this", "note that I got blocked on X", "close the day", "make the retro", "what do I say in daily". Operates the ~/Documents/WorkLog vault (adapted Karpathy pattern): raw Monday+git capture in raw/ and AI synthesis in daily/, frentes/, impedimentos/, and retro/.
---

# worklog

## Overview

All skill operation, generated notes, prompts, and user-facing responses must be in English.

Maintains the **WorkLog** vault (`~/Documents/WorkLog`), a **time-based work
journal** written mostly by AI so the user has ready material for **daily** and
**retro**. Follows the **Karpathy LLM Wiki** pattern: `raw/` is the immutable raw
layer (Monday snapshots + day commits + notes), and `daily/`, `frentes/`,
`impedimentos/`, `retro/` are synthesized and linked by AI.

- **Sources:** Monday (via `overview-do-dia`/`monday-api`, **read-only**), git/code
  (day commits in worktrees), AI conversations, manual notes.
- **Work split:** `worklog.sh` only does mechanical IO (call overview, collect git,
  ensure the daily skeleton). **YOU (the AI) write the prose**, reading `raw/` and
  following the vault `AGENTS.md`.

## Golden rule

- **Never** call the Monday API directly. Monday reads only through
  `overview-do-dia` (which uses the `monday.sh` gateway from `monday-api`).
- **`raw/` is immutable** — only append captures, never rewrite.
- **Anti-hallucination:** "Done" only enters if it comes from `raw/` (Monday/git)
  or is confirmed by the user. Do not invent deliveries; cite the source for each fact.
- This skill **does not** write to Monday. If the user asks for a Monday action,
  that is the `monday-api` skill, with confirmation.

## Prerequisites

- `MONDAY_API_TOKEN` exported (for `abrir`/`fechar`):
  `export MONDAY_API_TOKEN="$(cat ~/.config/monday/token)"`.
- `jq`, `git`. Vault at `~/Documents/WorkLog` (path in `config.json`).

## Note layout (minimal elegant)

Every note follows a single visual style, **native to Obsidian** (no plugins):
compact title with emoji + readable date (`# 📅 Jun 09 · Tuesday`), a
`> [!abstract]` summary just below, `##` headers with a fixed emoji anchor per
section (📋 Plan · ✅ Done · 🚧 Blockers · 💡 Decisions), `- [ ]` tasks where there
is progress, priority by colored dot, open blocker in `> [!warning]` (resolved in
`> [!success]`), clean frontmatter with `tags: [type]`, and `---` divider before
the closing block. **The layout source of truth is the "Visual language" section +
the "Anatomies" in the vault `AGENTS.md`** — read them before writing. The daily
skeleton is created by `ensure-daily`; frentes/impedimentos are live models and
there is `retro/_template.md`.

## Procedure (the 4 verbs)

Run commands from the skill folder. Always **read the vault `AGENTS.md`** before
writing prose.

### 1. open the day (morning / "open the day", "what do I have today")
```bash
export MONDAY_API_TOKEN="$(cat ~/.config/monday/token)"
./worklog.sh abrir inicio
```
This saves `raw/<today>/monday.json` and ensures `daily/<today>.md`. **Then you:**
- Fill the daily **Plan** section, prioritized (overdue → failed/reviews → in
  progress → to do), reading the printed JSON.
- Bring relevant **open blockers** from `impedimentos/` to the top.
- Append an `abrir-dia` entry to `log.md` and update "Latest dailies" in `index.md`.

### 2. record (during the day / "record this", "note that…")
- The user reports progress/decision/blocker (or you capture it from the session).
- Ensure the daily exists: `./worklog.sh ensure-daily`.
- **You write:** append to today's daily (Done / Blockers / Decisions) **and**
  update the corresponding `frentes/<slug>.md` and/or open/update
  `impedimentos/<slug>.md` (frontmatter `status`, `aberto_em`).
- For long raw user notes, also save them in `raw/<today>/notas.md`.

### 3. close the day (end / "close the day", "wrap up")
```bash
export MONDAY_API_TOKEN="$(cat ~/.config/monday/token)"
./worklog.sh fechar fim
```
Saves `raw/<today>/monday.json` (end mode) and `raw/<today>/git.md`. **Then you:**
- Complete **Done** (correlating commits from `git.md` to initiatives — use the
  `frentes` map in `config.json` as a hint, but trust what git reported) and
  **Blockers**; mark resolved blockers with date.
- Write the **"For tomorrow's daily"** block (did / will do / blocked on).
- Update `frentes/`, `index.md`; append `fechar-dia` to `log.md`.

### 4. run the retro (end of sprint/week / "make the retro")
- Read `daily/YYYY-MM-DD.md` files from the period (for example, the ISO week).
- Generate `retro/YYYY-Www.md`: deliveries, **recurring** blockers, decisions,
  improvement actions. Link with `[[frentes/...]]` and `[[impedimentos/...]]`.
- Append `retro` to `log.md`.

## Error handling

- Missing token → ask for `export MONDAY_API_TOKEN=...` (do not bypass).
- Empty `git.md` → day without commits by the author; record only what came from
  Monday/user report.
- Worktree/branch diverges from `CLAUDE.md` → normal (branches change); use what
  `git-dia` reported and adjust the `frentes` map in `config.json` if desired.

## Configuration (`config.json`)

- `vault_path`: vault path (supports `~`).
- `git_author`: author used in `git log` (project default: `cako`).
- `repos`: repo roots scanned by `git-dia` (each covers its worktrees).
- `overview_script`: relative path to `overview.sh`.
- `frentes`: initiative→branches map, only a hint for correlating commits.

## Test (no network)

```bash
./test-worklog.sh
```
Creates a temporary vault and validates `ensure-daily` (sections + idempotence),
without touching Monday.
