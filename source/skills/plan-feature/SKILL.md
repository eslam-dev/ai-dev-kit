---
name: plan-feature
description: Plan a non-trivial feature before implementation, using spec-lite for large work.
---
# Plan Before Implementation

Use when the user requests a plan or the change spans multiple boundaries.

Inspect first via the project index (`ai-dev query`, `PROJECT_MAP.md`, `SCHEMA.md`). Produce: current flow, desired flow, assumptions, affected components, schema/API changes, permissions, jobs/events, rollout, tests, risks, and ordered tasks. Do not edit production code during this skill unless explicitly requested.

## Spec-lite for Tier L/XL work

For large or multi-session features (Tier L/XL per the router rule), persist the plan instead of keeping it in conversation:

```bash
ai-dev spec <slug>
```

This scaffolds `.ai/specs/NNN-slug/{spec.md,plan.md,tasks.md}`. Rules:
- Mark every unknown in spec.md as `[NEEDS CLARIFICATION: specific question]` — never assume silently. Ask the user in one batched round; implementation may not start while any marker remains.
- plan.md answers the gates: simplicity, framework-direct usage, tests-first for money/auth/tenancy paths.
- tasks.md uses `[ID] [P] [Story]` grammar with exact file paths; the Foundational phase blocks all story work; each story phase ends with an independently-testable checkpoint. `[P]` tasks can be delegated in parallel (`run-project-team` for XL).
- On "done": re-read tasks.md, verify every checkbox against the codebase, append any gap as new tasks, and repeat until none remain.

Small/medium tasks skip spec-lite entirely — full ceremony on a small fix wastes more tokens than it saves.
