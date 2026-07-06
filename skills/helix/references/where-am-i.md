# Procedure: where-am-i (locate yourself / resume initiative)

Use when you need to discover where you are, which repo/branch you are in, or
resume an initiative after switching tasks.

All prompts, reports, and user-facing responses from this procedure must be in English.

## Steps

1. **Current worktree path**

   ```bash
   git rev-parse --show-toplevel
   ```
   If the path is **not** inside `worktrees/<initiative>/<repo>`, you are probably
   in a **root repo** — stop and warn: no work/commit should happen here.

2. **Real origin repo**

   ```bash
   git rev-parse --git-common-dir
   ```
   The returned `.git` directory belongs to the origin root repo (example:
   `…/web-pharmachatbot/.git` → origin repo `web-pharmachatbot`).

3. **Current branch**

   ```bash
   git rev-parse --abbrev-ref HEAD
   ```

4. **Derive the initiative** from the path: in `worktrees/<initiative>/<repo>`,
   `<initiative>` is the second-to-last folder. The expected branch is
   `<initiative>` with the first `-` changed to `/`.

5. **Read the Active initiatives map** in the base root `CLAUDE.md` (walk upward
   until you find the folder containing `worktrees/`). Cross-check the current
   initiative with the map to recover the goal and other involved repos.

6. **Report** briefly:

   > You are in initiative **`<type>-<slug>`** (goal: …), origin repo
   > **`<repo>`**, branch **`<type>/<slug>`**.
   > Other repos in this initiative: …. Other active initiatives: ….

## Quick coherence check

- Branch == initiative folder name (with `-`→`/`)? If not, warn (divergence).
- Branch is `main`/`master`/`develop`? If yes, **alert**: you should not work/commit
  on a protected branch inside an initiative worktree.
