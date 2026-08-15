# Tasks: {{SLUG}}

> Grammar: `[ID] [P?] [Story] description with exact file paths`.
> `[P]` = parallelizable (different files, no dependency on incomplete tasks).
> Phases run in order; **no user-story work starts until Foundational is done.**
> Completion gate: every task checked, tests green, no `[NEEDS CLARIFICATION]`
> markers anywhere in this spec directory.

## Phase 0 — Foundational (blocking)

- [ ] T001 [US-*] [migration/config/contract work every story depends on — exact paths]

## Phase 1 — US-1 (P1, MVP)

- [ ] T101 [US-1] [task with exact file path]
- [ ] T102 [P] [US-1] [parallelizable task with exact file path]

Checkpoint: US-1 independently testable and passing.

## Phase 2 — US-2 (P2)

- [ ] T201 [US-2] ...

Checkpoint: ...

## Phase N — Polish

- [ ] T901 [regression tests, docs, index refresh (`ai-dev .`)]
