# Procedure: review-pr (multi-agent review by dimension)

Use **when creating a PR for one repo** (after implementing the plan and getting
user approval) or when reviewing an already open PR. Creates the PR in the
**project standard**, dispatches one **read-only subagent per dimension** (in
parallel), consolidates findings, applies fixes by severity, runs regression, and
**iterates at most 2 times**. Ends by committing fixes, posting **one comment per
finding** on the PR (marked `APPLIED`/`NOT APPLIED`), and delivering a summary.
**Never merges** and **never brings up infrastructure**.

All prompts, subagent briefs, PR comments, commits, reports, and user-facing
responses from this procedure must be in English.

Scope: **one round per PR/repo** — operates on the diff of a single repo.

## Steps

### 1. Precondition (`where-am-i`)

Confirm context with `where-am-i`. The current worktree MUST be in
`worktrees/<initiative>/<repo>/`, on branch `<type>/<slug>`. If it is in a root repo
or protected branch → **stop** (same rules as `guard`).

```bash
git rev-parse --show-toplevel        # inside worktrees/<initiative>/<repo>
git rev-parse --abbrev-ref HEAD      # <type>/<slug>
gh pr view --json number,baseRefName,headRefName,url   # PR already exists?
```

### 1.1. Create the PR (project standard)

**Before anything else, require `gh` authentication:**

```bash
gh auth status
```

If `gh` **is not authenticated** (command fails / "not logged in") → **BLOCK and
return**:

> `gh` is not authenticated. Run `gh auth login` (or `! gh auth login` in this chat)
> before creating/reviewing the PR. See the framework setup (README) to install and
> log in to GitHub CLI.

Do not try to create the PR without authentication.

If there is **no existing** PR for the current branch (and the plan has been
implemented and **approved by the user**), create it using the **fixed standard**:

- **head** = **current branch** (`<type>/<slug>`).
- **base** = **`develop`**.
- Use the repo **PR template** (`.github/PULL_REQUEST_TEMPLATE.md`, if it exists)
  as the body, filled in.

```bash
gh pr create --base develop --head "$(git rev-parse --abbrev-ref HEAD)" \
  --title "<conventional, English>" --body-file .github/PULL_REQUEST_TEMPLATE.md
```

> **Base and target are fixed (`current branch → develop`).** Change base or target
> only if this is **EXPLICITLY written in the user's prompt** (for example:
> "open the PR to `main`"). Without explicit instruction, **always** use `develop`.

If the PR already exists, continue directly to step 2.

### 2. Diff collection

Get the PR diff and detect whether it touches frontend:

```bash
base=$(gh pr view --json baseRefName -q .baseRefName)
git diff "origin/$base...HEAD" --stat
git diff "origin/$base...HEAD"
```

**Touches frontend?** If any changed file belongs to a frontend/UI repo (for
example `web-pharmachatbot`, or screen files with `.tsx`/`.vue`/`.css`/`.scss`) →
**activate the design/UI agent**; otherwise, **do not** dispatch it.

### 3. Fan-out — one read-only subagent per dimension

Use `superpowers:dispatching-parallel-agents` (the `Agent` tool) to dispatch, **in
parallel**, one subagent per dimension. **All are read-only**: they only report
findings and **never edit files** (fix application happens later, sequentially, by
you — this avoids write conflicts in the worktree).

Dimensions:

| Agent | Focus |
|---|---|
| **logic** | bugs, edge cases, null/undefined, off-by-one, wrong conditions, race conditions |
| **patterns** | repo patterns, SOLID, coupling, reuse, naming, structure |
| **tests** | diff coverage, missing cases, fragile tests, whether behavior is validated |
| **performance** | N+1, memory leaks, expensive loops, re-renders, bundle size |
| **security** | injection, leaked secrets, authz/authn, input validation, vulnerable deps |
| **design/UI** | *only if frontend is touched* — adherence to `design.md` tokens and rules |

**Brief for each subagent** (self-contained): include the diff (or relevant hunks),
the absolute repo path, the dimension, and the severity rubric. Embed project rules
in the brief when they apply:

- **`neo-api`:** the agent checks **repo documentation first**; it uses source code
  only if more context is needed (saves tokens).
- **design/UI:** the agent loads root `design.md` and checks existing tokens (for
  example `primary-base #e6284a`, `CARD_RADIUS 18px`, `SHADOW_MD`) and Do's &
  Don'ts — never invents ad-hoc values.

Each subagent returns **only** structured findings, one per item:

```yaml
- file: <path relative to repo>
  line: <number or range>
  dimension: <logic|patterns|tests|performance|security|design>
  severity: <low|medium|high>
  description: <the objective problem>
  suggested_fix: <concrete change>
```

### 4. Consolidation

Merge findings from all agents and **deduplicate**: the same line flagged by
multiple dimensions becomes **one** item (record the converging dimensions).

### 5. Apply by severity

- **low / medium →** apply the fix **automatically** in the worktree (sequential
  edits, by you). Mark → `APPLIED`.
- **high (business rule) →** **DO NOT apply**. These findings change business
  rules / observable product behavior, or encode a non-trivial architecture
  decision. For each one: **ask explicit permission** before any edit. Mark →
  `NOT APPLIED`.

**Regardless of severity, EVERY finding becomes a PR comment** (step 8). Only the
mark changes (`APPLIED` for fixed items, `NOT APPLIED` for pending/waiting items).

### 6. Regression (after applying fixes)

Run the **full regression** for this worktree repo:

1. **Unit tests** — `guard` suite (command from the worktree `CLAUDE.md`, field
   "Unit tests"; detect package manager by lockfile — pnpm/yarn/npm/poetry/pip).
2. **Lint + typecheck** for the repo.
3. **Integration** — *only if the environment is already up* (same rule as
   `finish-feature`: the agent **observes**, never **provisions** infrastructure).

Apply `superpowers:verification-before-completion`: only say "passed" with real
output in hand. If anything breaks → `superpowers:systematic-debugging`.

### 7. Loop (max 2 iterations)

If regression **broke** something, **or** new actionable findings appeared after
fixes → **repeat** from step 3 (re-dispatch agents on the updated diff).

**Maximum 2 iterations.** On the 2nd, **finish** even if pending items remain —
they become reported items (steps 8 and 9), not a blocker.

### 8. PR comments — **1 comment = 1 problem**

**Bot identity (optional).** By default comments use the account logged into `gh`
(the user's account). To post as a **GitHub App** (`<app>[bot]`), generate an
installation token **only for the comment step**:

```bash
eval "$(scripts/helix-bot-token.sh)"   # exports App GH_TOKEN (valid ~1h)
```

- If the script exists and config is complete (env `HELIX_BOT_*` or
  `~/.helix/bot.env`) → `gh pr comment`/`gh api` in this step use the **bot**.
- If the script fails or config is missing → **fall back to the user's `gh`** (do
  not block; only comment identity changes, not the ability to comment).
- **PR creation** (step 1.1) remains on the user's account — only review comments
  use the bot. See the App setup in README.

Post **all findings** as PR comments through `gh`, **regardless of severity** (low,
medium, or high). Rules:

- **1 comment = 1 problem.** Do not group unrelated findings into one comment.
- **Filter and concatenate similar findings.** Findings that are the **same
  problem** (same cause, same file/area, or solved by the same fix) become **one**
  comment. Use this to reduce noise.
- **Maximum 10 comments per PR.** If more than 10 remain after
  deduplication/concatenation, **prioritize by severity** (high > medium > low) and
  **group the excess** into thematic comments until it fits the ceiling. Never
  exceed 10.
- **Each comment starts with the mark:**
  - `APPLIED` — fix already applied in the worktree (low/medium).
  - `NOT APPLIED` — pending; high business-rule item waiting for permission, or
    unfixed excess. For HIGH items, include the **permission request** to apply.

**Comment format:**

```text
<APPLIED | NOT APPLIED> · <dimension> · <severity>

<objective description of the problem>

Fix: <what was done, or what is suggested>
```

Prefer posting **inline** (anchored at `file:line`); fall back to a general PR
comment only when anchoring does not apply.

### 9. Closing

- **Commit applied fixes** — follow `guard`: run the `guard` checklist
  (confinement, folder==branch, green units), and commit in **English**,
  **conventional commits**, **subject-only** + Co-Author footer. Example:
  `fix: address PR review edge cases`.
- **Chat summary** — table by **dimension × severity** (applied × pending), number
  of posted comments (remember: ceiling of 10), number of iterations, and
  regression status.
- **Do not merge.** To finish the branch, use `finish-feature` /
  `superpowers:finishing-a-development-branch`.

## Golden rule

Subagents **only observe and report**; the orchestrator edits, and only for
low/medium severities. **HIGH (business rule) always asks permission.** **Every
finding becomes a PR comment (1 comment = 1 problem, marked `APPLIED`/`NOT
APPLIED`), concatenating similar findings and capped at 10 comments per PR.**
Never more than **2 iterations**. Never merge, never bring up infrastructure.
