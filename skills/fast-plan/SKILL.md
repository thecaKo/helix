---
name: fast-plan
description: Use when an approved spec/design exists and this base needs an implementation plan for a multi-task feature. It replaces superpowers:writing-plans here. Triggers: "create plan", "implementation plan", "tasks.md", brainstorming handoff.
---

# fast-plan

## Language

All skill operation, prompts, generated plans, and user-facing responses must be in English.

## Overview

The plan is an **execution contract** (`tasks.md` spec-kit style), not a code
draft. The subagent writes code during execution through TDD; the plan states
**what**, **where**, and **how to verify** — never the finished code.

**Announce:** "Using fast-plan to create the implementation plan."

**Save to:** `sdd/plans/YYYY-MM-DD-<feature>-tasks.md` (in the pharmatree hub —
`docs/` is a cloned repo and gitignored).

## Document structure

1. **Header** — Goal (1 sentence), Architecture (2–3 sentences), Stack, spec link.
2. **Context Pack** — written ONCE; fast-exec injects it verbatim into each
   subagent so nobody re-explores the repo:
   - Exact test/lint/build commands (per repo, if multi-repo).
   - Applicable conventions (code patterns, CLAUDE.md/design.md rules).
   - Map of touched files — 1 line per file describing its current role.
3. **Tasks** grouped by dependency layer (L1 → L2 → …).

## Task format

```markdown
### T3 [P] [fast] — Payload validator  (layer L2, depends on: T1)
**Files:** Create: src/validators/payload.ts · Test: tests/validators/payload.test.ts
**Acceptance:** accepts payload with X; rejects Y with error Z
**Tests:** expected named cases (without their code)
**Design:** only when there is a non-obvious decision — then include a snippet
```

## Rules

| Rule | Detail |
|---|---|
| Layers | Every task declares layer and dependencies; layers form a DAG (no cycles) |
| Same-layer dependency | **Depending on a task in the SAME layer is forbidden** — if T depends on T', T moves to the next layer. Tasks in the same layer are always mutually independent |
| `[P]` | Parallelizable: files are **disjoint** from every other `[P]` in the same layer |
| Tier | `[fast]` = mechanical (1–2 files, complete spec) → fast model; `[opus]` = integration/judgment/multi-file → Opus |
| Size | Executable in ≤ ~30 min by one subagent; split anything larger |
| Acceptance | Verifiable by test or command — never "handle errors properly" |

## Forbidden

- **Complete code in steps** (the inverse of writing-plans): code appears only in
  **Design**, when the decision is not obvious to a competent developer.
- Placeholders: "TBD", "TODO", "similar to task N", vague acceptance.
- `[P]` on two tasks in the same layer that touch the same file.
- Referencing a type/function that no task defines.

## Self-review (before delivery)

1. **Coverage:** does every spec requirement point to a task? List gaps.
2. **Disjointness:** do `[P]` tasks in each layer have disjoint files?
3. **DAG:** do dependencies respect layers (nothing depends on a later layer
   **or the same layer** — intra-layer dependency = task in the wrong layer)?
4. **Tiers:** does any `[fast]` require judgment or touch 3+ files? Promote to `[opus]`.
5. **Verifiability:** does every acceptance criterion have an associated test/command?

Fix inline and continue.

## Handoff

"Plan saved at `sdd/plans/<file>`. Execute it with the **fast-exec** skill."
Do not offer executing-plans or subagent-driven-development.
