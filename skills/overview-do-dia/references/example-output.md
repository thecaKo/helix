# Output examples (writing reference)

These are examples of the **final text** the agent writes from the `overview.sh`
JSON. They are not raw JSON — they are what the user reads.

## Mode `inicio` (day plan)

```
Day overview — start (09:02)

Overdue (1) — resolve first
  • Fix login bug (QA failed it) — Sprint · Failed · High · due 06/08

Failed tests (1)
  • Connector tests failed — Sprint · Critical

Pending code review (1)
  • atendimentos-v2 PR waiting for review — Sprint · Critical · due 06/12

In progress (1) · To do (2)
  • Implement dashboard outbox — Sprint · Medium
  • Refine pharma-agent card — Backlog · Low · today

Focus suggestion: kill the overdue item and failures before lunch; the review PR
unblocks the team.
```

## Mode `meio` (progress / blockers)

```
Day overview — mid (14:10)

Still stuck:
  • Connector tests failed (Critical) — still failing
  • atendimentos-v2 PR — review still pending

Highest urgency now: Fix login bug (overdue, High).
If anything from the morning is already closed, the natural next step is the review PR.
```

## Mode `fim` (closing)

```
Day overview — end (18:05)

Still open for tomorrow:
  Overdue: Fix login bug (QA failed it) — overdue since 06/08
  Failed tests: Connector tests failed — Critical
  Review: atendimentos-v2 PR — waiting for review

Attention: 1 overdue item and 1 failed test remain pending. Good starting point
for tomorrow morning.

(The skill does not store day history — this is the current Monday state.)
```
