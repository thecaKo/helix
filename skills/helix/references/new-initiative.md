# Procedure: new-initiative (create a consistent multi-repo initiative)

Use this to open a new work initiative spanning 1+ repos, following the helix
naming convention.

All prompts, generated files, and user-facing responses from this procedure must
be in English.

## Required inputs

- `type` — `feat` · `fix` · `refactor` · `chore` · `docs` · `test` · `perf` · `build` · `ci`.
- `slug` — short descriptive kebab-case (example: `atendimentos-grupos`).
- `repos` — list of involved root repos (exact folder name for each one).

Derived:
- Initiative folder: `worktrees/<type>-<slug>/`
- Branch (the SAME in every repo): `<type>/<slug>`

If any input is missing, **ask** before creating anything.

> **Bare prompt → ask for the name.** If the request is vague (for example,
> "I need to start a new project", "create a new initiative"), **do not invent**
> the folder/branch name. Ask the user for the **initiative name** (the kebab-case
> `slug`) and, if it cannot be inferred, the `type` too. Folder and branch derive
> from that (`worktrees/<type>-<slug>/` and branch `<type>/<slug>`). Continue only
> after the answer.

> **Always ask WHICH repos to include.** Even if the user did not specify them,
> **do not assume** the `repos` list — discover available repos in the base (step 1)
> and **explicitly ask** the user which ones they want as worktrees in this
> initiative. Continue to creation only after the answer.

## Steps

1. **Move to the base root** (the folder that contains `worktrees/` and the root repos).

1b. **List available repos and ask which ones to include.** Detect root repos
   (each subfolder that is a git repository, excluding `worktrees/`):

   ```bash
   for d in */; do [ -d "$d/.git" ] && echo "${d%/}"; done
   ```
   Show this list to the user and **ask which repos** they want for the initiative.
   Use **only the confirmed repos** as the `repos` list for the next steps.

2. **Create the initiative folder**

   ```bash
   mkdir -p worktrees/<type>-<slug>
   ```

3. **For each listed repo**, create the worktree directly on the new branch,
   **always starting from the updated `develop` branch of the root repo** (never
   from whatever branch the root repo is currently on). First update `develop`:

   ```bash
   git -C <repo> fetch origin develop
   ```
   Then create the worktree based on `origin/develop`:
   ```bash
   git -C <repo> worktree add "worktrees/<type>-<slug>/<repo>" -b "<type>/<slug>" origin/develop
   ```
   If the branch already exists (resumed initiative), use:
   ```bash
   git -C <repo> worktree add "worktrees/<type>-<slug>/<repo>" "<type>/<slug>"
   ```
   If any repo does not have a `develop` branch, **stop and ask the user** which
   base branch to use — do not assume `main`/`master`.

3b. **Copy environment files** from the root repo to the worktree, **only if they
   exist** (`.env` and `.env.test` are outside git, so they do not appear in the
   worktree). For each repo, copy only what exists — if neither exists, do nothing:

   ```bash
   for f in .env .env.test; do
     [ -f "<repo>/$f" ] && cp "<repo>/$f" "worktrees/<type>-<slug>/<repo>/$f"
   done
   ```

3c. **Install dependencies** in each worktree, detecting the package manager from
   the lockfile (do not assume npm). Run inside the repo worktree folder:

   ```bash
   cd "worktrees/<type>-<slug>/<repo>"
   if   [ -f pnpm-lock.yaml ];     then pnpm install
   elif [ -f yarn.lock ];          then yarn install
   elif [ -f package-lock.json ];  then npm ci || npm install
   elif [ -f package.json ];       then npm install
   elif [ -f poetry.lock ];        then poetry install
   elif [ -f requirements.txt ];   then pip install -r requirements.txt
   fi
   ```
   If the repo has no recognized dependency manifest, skip this step.

4. **Generate the per-repo-worktree `CLAUDE.md`** in each
   `worktrees/<type>-<slug>/<repo>/CLAUDE.md`, from
   `templates/CLAUDE.worktree.md`, filling in: initiative, origin repo, branch,
   role (web/api/neo-api/…), goal (1-2 lines).

5. **Create the `AGENTS.md` mirror** beside each `CLAUDE.md`:

   ```bash
   ln -sf CLAUDE.md "worktrees/<type>-<slug>/<repo>/AGENTS.md"
   ```
   If the target tool does not follow symlinks, copy the content instead of linking.

6. **Update the Active initiatives map** in the root `CLAUDE.md`: add a line
   `| <type>-<slug> | <repos> | <type>/<slug> | in progress — <goal> |`.

7. **Report** the created initiative, listing worktree paths and branch.

## Validation

- `git -C <repo> worktree list` must show the new worktree at the correct path, on
  branch `<type>/<slug>`, without `prunable`.
- Confirm the subfolder has **the exact repo name** (not an alias).
- Confirm the new branch started from `develop`: `git -C "worktrees/<type>-<slug>/<repo>"
  merge-base --is-ancestor origin/develop HEAD` must succeed (the new branch
  contains the tip of `origin/develop`).
