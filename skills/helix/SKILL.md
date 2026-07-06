---
name: helix
description: >-
  Use when working in a multi-repo base organized with worktrees (helix
  structure). Triggers when the agent needs to LOCATE ITSELF ("where am I",
  "what repo/branch is this", "resume initiative"), CREATE a new multi-repo
  initiative ("new initiative", "create worktree"), CHECK before committing
  ("before committing", "git commit", "can I commit here"), CREATE/REVIEW a PR
  ("create PR", "open PR", "PR is open", "review the PR", "run agents on the PR"),
  FINISH a feature ("feature is done", "end of feature", "run integration tests"),
  or REPAIR broken worktrees ("worktree prunable", "broken git worktree",
  "sync map"). Ensures the agent never commits in the root repo or wrong
  branch/folder and that the test flow (unit tests before commit, integration at
  feature end) is respected.
---

# helix — multi-repo orchestration with worktrees

## Language

All skill operation, generated files, prompts, reports, and user-facing responses
must be in English unless preserving an existing external contract, command,
branch, path, token, API, or project-specific literal.

Framework for working on **multiple initiatives at the same time** across
**multiple repositories**, using git worktrees, without touching root repos or
committing in the wrong place.

## Topology (memorize)

```
<base>/                                 root: aggregates repos · CLAUDE.md = ORCHESTRATOR
├── <repo-a>/  <repo-b>/  <repo-c>/     ROOT repos (origin) — NEVER touched/committed
└── worktrees/
    └── <type>-<slug>/                  one INITIATIVE (run 2-3 in parallel)
        ├── <repo-a>/  CLAUDE.md+AGENTS.md   worktree · branch <type>/<slug>
        ├── <repo-b>/  CLAUDE.md+AGENTS.md   worktree · branch <type>/<slug>
        └── <repo-c>/  CLAUDE.md+AGENTS.md   worktree · branch <type>/<slug>
```

## Convention (conventional commits) — inviolable

| Element | Pattern | Example |
|---|---|---|
| Initiative folder | `<type>-<slug-kebab>` | `feat-atendimentos-grupos` |
| Branch (the SAME in every initiative repo) | `<type>/<slug-kebab>` | `feat/atendimentos-grupos` |
| Repo subfolder | **exact** origin repo name | `web-pharmachatbot` |
| Commit message | conventional, **subject-only** (no body) + Co-Author footer | `feat: add X` |

`type` ∈ `feat` · `fix` · `refactor` · `chore` · `docs` · `test` · `perf` · `build` · `ci`.
Deterministic folder↔branch mapping: replace the **first** `-` with `/`.

## Golden rules

1. **Root repos NEVER receive commits.** All work lives in `worktrees/<initiative>/<repo>/`.
2. **One initiative = one branch** `<type>/<slug>` across its repos.
3. **Before ANY commit**, run the `guard` procedure — it includes the **unit test
   suite** (must pass) before committing.
4. **At the end of each feature**, run the `finish-feature` procedure — it runs
   **integration tests** (only if the environment is already ready; the agent never
   brings up infrastructure by itself).
5. **Commits in English**, conventional commits, **subject-only** (no body) +
   Co-Author footer.
6. **Truth comes from live git** (`git rev-parse`), never from a saved file.
7. **In the `neo-api` repo, prioritize documentation.** Check repo docs first and
   only use source code **if more context is needed** — saves tokens.

## Development workflow (superpowers)

**Prerequisite:** the [superpowers](https://github.com/obra/superpowers) plugin
must be installed for Claude. helix organizes *where* work happens; superpowers
organizes *how*. Use superpowers skills in each phase:

| Phase | Superpowers skill |
|---|---|
| Before creating a feature/idea | `superpowers:brainstorming` |
| Turn spec into plan | `superpowers:writing-plans` |
| Implement (always through tests) | `superpowers:test-driven-development` |
| Bug / test failure / strange behavior | `superpowers:systematic-debugging` |
| Before saying "done/passing" or committing | `superpowers:verification-before-completion` |
| Request/receive code review | `superpowers:requesting-code-review` · `superpowers:receiving-code-review` |
| After opening the PR (multi-agent review by dimension) | **review-pr** (`references/review-pr.md`) — complements the code review above |
| Finish the branch (merge/PR/cleanup) | `superpowers:finishing-a-development-branch` |

Typical initiative flow: `brainstorming` → `writing-plans` → (per task) `TDD` /
`systematic-debugging` → `guard` (unit tests + commit) → repeat → at the end:
`finish-feature` (integration tests) → `finishing-a-development-branch`.

## Routing — choose the procedure

| Intent | Procedure | File |
|---|---|---|
| "Where am I? What repo/branch? I am lost / resume" | **where-am-i** | `references/where-am-i.md` |
| "Create a new multi-repo initiative" | **new-initiative** | `references/new-initiative.md` |
| "I will commit / can I commit here?" | **guard** | `references/guard.md` |
| "Create PR / PR is open / review PR / run agents on PR" | **review-pr** | `references/review-pr.md` |
| "Feature is done / run integration tests" | **finish-feature** | `references/finish-feature.md` |
| "Broken worktree / prunable / sync map" | **doctor** | `references/doctor.md` |

Read the corresponding reference file and follow it step by step. When context is
unclear, **always** start with `where-am-i`.
