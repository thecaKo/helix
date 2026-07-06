---
name: overview-do-dia
description: Use when the user asks for a workday overview — "how is my day", "what do I have today", "day overview", "start/mid/end of day", "my tasks", "what is missing", "pending code reviews", "failed tests". Reads the user's Monday assignments read-only and returns an urgency-prioritized summary, with emphasis by time (start = plan, mid = progress, end = closing).
---

# overview-do-dia

## Overview

All skill operation, summaries, prompts, examples, and user-facing responses must be in English.

Gives the user a **workday overview** from Monday.com, **read-only**. Shows assigned
tasks, pending code reviews, and failed tests ordered by urgency (deadline +
priority + status type). Designed to run at the **start, middle, and end** of the day.

- **Single source:** Monday through the `monday.sh` gateway from the `monday-api`
  skill. Never build direct API calls — `overview.sh` already calls `monday.sh`.
- **Read-only:** this skill **never** changes Monday. If the user asks for an
  action (move card, comment, etc.), that is a different operation — use the
  `monday-api` skill with confirmation, not this one.

## Prerequisites

- `MONDAY_API_TOKEN` available for `monday.sh`. The token is stored locally outside
  git at `~/.config/monday/token`; pass it per call with
  `export MONDAY_API_TOKEN="$(cat ~/.config/monday/token)"`. If the file does not
  exist and there is no env var, **stop and ask** for the token — do not search
  other files.
- `config.json` is already calibrated for board **"Desenvolvimento 💨"**
  (`18391375493`), user **"Carlos Felix - Dev 3"**, with real column IDs (Etapa,
  Criticidade, Resp., Par, Conclusão). For another board, adjust `board_ids`,
  `columns.*` (column IDs), and `status_categories`.

## Procedure

1. **Discover the mode.** If the user explicitly said start/morning, mid/afternoon,
   or end/close, pass it as an argument. Otherwise, let the script infer it by time.

2. **Run the collector** (from the skill folder, with the token in the environment):
   ```bash
   export MONDAY_API_TOKEN="$(cat ~/.config/monday/token)"
   ./overview.sh            # infers mode by time
   ./overview.sh inicio     # or: meio | fim
```
   It resolves your user by name, scans `board_ids` (with pagination), collects
   items where you are **Resp.** or **Par** (each item includes `role` and `group`),
   and prints **JSON** with `mode`, `counts`, and `buckets` (`atrasados`,
   `teste_reprovado`, `code_review`, `em_andamento`, `a_fazer`), each bucket already
   sorted by `urgency_score` (desc). Items where you are a partner come marked
   `role:"par"` — mention that in the text (you are not the main owner).

3. **Handle common errors** without bypassing the rule:
   - Missing token → ask for `export MONDAY_API_TOKEN=...`.
   - `board_ids` still has a placeholder → ask for the IDs and help fill
     `config.json`.
   - User not found → confirm the exact Monday `user_name`.

4. **Write the overview** from the JSON, in the tone of the **mode**:

   - **inicio (day plan):** start with `atrasados`, then `teste_reprovado` and
     `code_review` (they unblock others), then what to attack in `em_andamento` /
     `a_fazer`. Suggest a morning focus. Short and actionable.
   - **meio (progress/blockers):** highlight what likely moved and what is stuck —
     failed tests and reviews that remain pending. Point to the next item with the
     highest `urgency_score`.
   - **fim (closing):** what is still open and needs attention tomorrow; explicitly
     list failed tests/reviews still pending. Do not invent what was completed —
     the skill stores no history.

   Always: put `overdue` items at the top; cite `name`, `board`, `status`,
   priority, and deadline. Do not dump raw JSON — write a readable summary. See
   [`references/example-output.md`](./references/example-output.md).

## Classification configuration

`config.json` controls mapping (without changing code):

- `columns`: **explicit** board column IDs — `people_resp` and `people_par`
  (people columns), `status` (workflow status column, for example "Etapa"),
  `priority` (for example "Criticidade"), and `date` (for example "Conclusão").
- `status_categories`: which **Etapa labels** fall into each category
  (`teste_reprovado`, `code_review`, `em_andamento`, `a_fazer`, `concluido`).
  `concluido` is omitted from the overview.
- `priority_order`: Criticidade order (most to least urgent):
  `Urgente > Alta > Média > Baixa`.
- **Deadline note:** in this board, the date column is "Conclusão" (*closing* date),
  which active items almost always leave empty — so urgency is effectively driven by
  **status category + Criticidade**, and `atrasados` will rarely have items. This is expected.

## Test

Classification/urgency logic is testable without network:
```bash
./test-overview.sh
```
Uses [`references/fixture-items.json`](./references/fixture-items.json) and
`overview.sh --classify` (reads raw JSON from stdin, without calling Monday).

## Golden rule

Read-only and through `monday.sh`. If anything requires writing to Monday, **do not
do it here** — that is work for the `monday-api` skill, with explicit user confirmation.
