---
name: run-project-team
description: Stand up a scaled team (team-lead + frontend/backend developers + tester, with a CTO above multiple team leads) for a large task list or markdown backlog, instead of one specialist.
---
# Run Project Team

Use when a task list — inline or a markdown file — is too large or too parallel for one specialist to own safely (Tier XL in `05-agent-model-router.mdc`), or the user explicitly asks for a full team.

## When not to use
If the backlog is small enough for one specialist, delegate directly per `task-router` instead. Do not stand up a team for work one agent can do safely — coordination overhead must be justified.

## Procedure
1. Load the task list (parse the markdown file if one was given) and count distinct deliverable units.
2. Split units into frontend and backend, preserving dependency order within each (e.g. a backend endpoint before the frontend page that calls it).
3. Choose scale:
   - **Single workstream** (one coherent feature area): one `team-lead` owning both the frontend and backend split directly.
   - **Large / multiple workstreams**: one `team-lead` per independent workstream, split by domain/module — not only frontend vs backend.
   - **Very large / cross-team**: add one `cto` above all team leads for cross-workstream conflicts and final sign-off.
4. Each `team-lead` delegates its units to `team-frontend-developer` / `team-backend-developer`, then `team-tester`, then `reviewer`, per the handoff contract defined in `team-lead`.
5. Collect status from every team lead (done/blocked/at-risk) and surface blockers to the user rather than silently absorbing them.

## Concurrency
Run genuinely independent units in parallel; keep dependent units sequential within a workstream. A large backlog can grow into dozens of agents across the run — plan the work in waves rather than assuming unlimited simultaneous capacity, since only a bounded number of agents actually execute at any one instant regardless of how many are queued.

## Escalation
A team lead or the CTO must stop and involve the user on: unresolved architecture conflicts, ambiguous business rules, or any Critical/High finding from `reviewer` that blocks release.
