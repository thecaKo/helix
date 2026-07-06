# Procedure: finish-feature (finish feature + integration tests)

Use when concluding a feature/initiative, before opening a PR or integrating. Runs
**integration tests** — but **only if the test environment is already ready**. The
agent **never brings up infrastructure by itself** (docker, migrations, seeds): if
anything is missing, it only reports and stops.

All prompts, reports, and user-facing responses from this procedure must be in English.

## Steps

1. **Confirm context** with `where-am-i` (initiative, repos, branch). Ensure the
   whole feature has already been committed through `guard` (green unit tests in
   each repo).

2. **Check whether the test environment is ready** (only *read-only* checks):
   - test containers up? `docker ps` shows the expected services (for example,
     test MySQL/Redis)?
   - database reachable and **migrations** applied? (project ping/health-check)
   - **seeds** loaded, if the suite requires them?

   The exact command/health-check comes from the worktree `CLAUDE.md` (field
   "Integration environment"). Do not recreate or start anything — only observe.

3. **Decision:**
   - **Environment ready** → run the repo **integration test** suite (field
     "Integration tests" in the worktree `CLAUDE.md`; for example,
     `pnpm vitest:integration`). Use `superpowers:verification-before-completion`:
     report the real output. If it fails → `superpowers:systematic-debugging`.
   - **Environment NOT ready** → **do not execute** tests. Report exactly what is
     missing and **list the commands** for the user to prepare the environment (for
     example, `docker compose up -d`, `pnpm test:db:init`, seeds). Mark the feature
     as "integration pending — waiting for environment/manual execution".

4. **Repeat** step 3 for every repo involved in the initiative that has an
   integration suite.

5. **Finish the branch:** when tests that could run are green, use
   `superpowers:finishing-a-development-branch` to decide merge / PR / cleanup for
   the initiative. Update the status in the **Active initiatives map** in the root
   `CLAUDE.md`.

## Golden rule

The agent **observes** the environment, it does not **provision** it. In-memory
Mongo suites (MongoMemoryServer) do not depend on external infrastructure and can
run normally; suites that require MySQL/Redis/Docker only run if the user has
already brought the environment up.
