# Procedure: doctor (repair worktrees + sync map)

Use to fix `prunable`/broken worktrees and reconcile the Active initiatives map
with disk reality. **Non-destructive:** list and propose; only rename/move/remove
with explicit user confirmation.

All prompts, reports, and user-facing responses from this procedure must be in English.

## Steps

1. **Inventory by root repo**

   For each origin repo in the base:
   ```bash
   git -C <repo> worktree list
   ```
   Record paths, branches, and `prunable` markers.

2. **Repair stale paths** (moved worktrees → `prunable`)

   ```bash
   git -C <repo> worktree repair
   ```
   `repair` reconnects metadata to the new path. Run across the whole base if useful:
   ```bash
   git -C <repo> worktree repair worktrees/*/<repo>
   ```

3. **Prune orphans** (worktree whose directory no longer exists) — only after confirmation:

   ```bash
   git -C <repo> worktree prune
   ```

4. **Audit against convention.** For each worktree in `worktrees/<initiative>/<repo>`,
   flag (without auto-fixing):
   - subfolder name **≠** origin repo (`git rev-parse --git-common-dir`);
   - branch **≠** expected (`<initiative>` with `-`→`/`);
   - protected branch (`main`/`master`/`develop`) inside an initiative.

   For each divergence, **propose** the correction command (rename folder, create/
   switch branch) and ask for confirmation.

5. **Regenerate the Active initiatives map** in the root `CLAUDE.md` from real
   state: one line per initiative with `| initiative | repos | branch | status |`.
   Preserve manually filled goal/status fields when possible.

6. **Report** a summary: what was repaired, what was pruned (if confirmed), and the
   list of divergences still waiting for a decision.

## Reminder

Git is the source of truth. This procedure does not invent state: it reads
`worktree list` + `git-common-dir` and adjusts documentation/metadata to reflect
reality.
