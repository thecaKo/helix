---
name: card-retro
description: Use when FINISHING an initiative/card to record a short retrospective in the Second Brain vault. Triggers: "record the retro", "card-retro", "document the initiative in second brain", "close the card in second brain". Ensures (guard) the task README is updated, ASKS for the card link and dates, and writes daily-notes/<YYYY-MM>/<YYYY-MM-DD>-<slug>.md answering: what we did, why we did it, what problem it solves, loose ends, and what could have been better.
---

# card-retro

## Overview

All skill operation, generated notes, prompts, and user-facing responses must be in English.

Records the **retrospective for an initiative/card** in the **Second Brain** vault
(`~/Documents/Second Brain/daily-notes/<YYYY-MM>/`), one file per card, using a
**minimalist** template. Answers are **synthesized by the AI** from the work done in
the session; the **card link and dates are requested from the user** (never invented).

The skill **lives in the helix repo** (`skills/card-retro/`); the generated file
lives **in the vault** and **does not** enter helix git.

## Golden rule

1. **GUARD — task README first.** Before writing the retro, the README for the
   module/repo touched by the initiative **MUST** reflect what changed. If stale,
   update it before proceeding. Without an up-to-date README, **do not record the retro**.
2. **ALWAYS ask the user** for the Monday card link, start date, and completion
   date. **Never invent** these three pieces of information.
3. **Minimalist template** — do not add sections, frontmatter, or decoration beyond
   `references/template.md`. Keep answers short and direct.

## Procedure

### 0. Guard — task README updated (BLOCKING)

Identify the README(s) for the module(s)/repo(s) changed by the initiative (for
example, `src/modules/<x>/README.md` in the touched repo). Check whether they
already describe **the current context of what changed** in this initiative. If
they **do not**, update them now (same style as the existing document, concise).
Continue only when the README reflects the change. If there is no applicable
README, state that and continue.

### 1. Collect from the user (mandatory)

Ask and **wait** for the three answers (do not continue without them):

- **Card link** on Monday.
- **Start date** (`YYYY-MM-DD`).
- **Completion date** (`YYYY-MM-DD`).

### 2. Enrich through Monday (degradable)

Extract the `pulse id` from the link and, via the **monday-api** skill, fetch the
card **title** and **status**. If the call fails or there is no token, **degrade**:
use only the link and continue (status/title stay blank).

### 3. Derive name and destination

- `slug`: kebab-case from the card title (or initiative name, if no title).
- `month`: `YYYY-MM` from the **completion date**.
- Folder: `~/Documents/Second Brain/daily-notes/<YYYY-MM>/` (create if missing).
- File: `<YYYY-MM-DD-completion>-<slug>.md`.

### 4. Write the retro

Fill `references/template.md` with the link, dates, status (if any), and the
**session-synthesized answers** to the five questions:

1. **What we did**
2. **Why we did it**
3. **What problem it solves**
4. **Loose ends** (what remained open / untreated)
5. **What could have been better**

Short, honest answers — no inflation. If a question has no real answer, say that
instead of inventing.

### 5. Confirm

Report the created file path. **Do not** commit the vault file in the helix repo.
