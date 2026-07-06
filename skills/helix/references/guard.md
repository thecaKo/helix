# Procedure: guard (pre-commit checklist)

**Always run before `git commit`** inside this base. Rule: *folder == branch +
protected branches blocked*. If any check fails → **refuse the commit and report**;
do not commit.

All prompts, reports, and user-facing responses from this procedure must be in English.

## Checklist

1. **Confinement — not a root repo**

   ```bash
   git rev-parse --show-toplevel
   ```
   The path MUST be inside `worktrees/<initiative>/<repo>`. If it is a root repo
   (origin) → **BLOCK**: root repos never receive commits.

2. **Confinement — changes do not leak**

   ```bash
   git status --porcelain
   ```
   All staged/modified files must belong to this worktree. No paths pointing
   outside it.

3. **Protected branch**

   ```bash
   git rev-parse --abbrev-ref HEAD
   ```
   If the branch is `main`, `master`, or `develop` → **BLOCK**. Initiatives work on
   their own `<type>/<slug>` branch.

4. **Folder == branch**

   - Initiative = second-to-last path folder: `worktrees/<initiative>/<repo>` → `<initiative>`.
   - Expected branch = `<initiative>` with the **first** `-` replaced by `/`.
   - Current branch MUST equal the expected branch. Silent divergence → **BLOCK**.

5. **Unit tests pass** (mandatory)

   Run the unit test suite for this worktree repo. The command comes from the
   worktree `CLAUDE.md` (field "Unit tests"); if not declared, discover it from
   `package.json`/project configuration (for example, `pnpm vitest:unit`, `npm test`).
   If it **fails** → **BLOCK**: fix it (use `superpowers:systematic-debugging`)
   before committing. Do not commit with red unit tests.

   Before claiming it passed, apply `superpowers:verification-before-completion`:
   evidence (real test output) before any success claim.

## If everything passes

Report and proceed:

> Commit allowed — initiative `<type>-<slug>`, repo `<repo>`, branch `<type>/<slug>`,
> unit tests green.

Commit message: **English**, **conventional commits**, **subject-only** (no body
paragraph), with the project co-author footer. Example:

```
feat: add contact sharing in support

Co-Authored-By: <per project standard>
```

## If it fails

Explain **which** check failed and the suggested fix (for example: "you are on
`develop`; switch to the initiative branch `feat/atendimentos-grupos` before
committing" or "you are in the root repo `web-pharmachatbot`; move to the worktree
at `worktrees/<initiative>/web-pharmachatbot`"). **Do not commit.**
