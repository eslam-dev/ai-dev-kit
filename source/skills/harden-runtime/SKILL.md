---
name: harden-runtime
description: Turn on Laravel's runtime guards so N+1 queries, silently discarded attributes, and destructive migration commands fail loudly instead of being forbidden only in prose. Use when hardening a project, adopting strict mode, or after an N+1 keeps coming back.
---
# Harden the Runtime

A rule that says "never write an N+1" is advisory. `Model::preventLazyLoading()` makes a lazy load
throw. This skill stages the second one in.

**The kit never writes into `app/`.** You apply these edits yourself, from
`assets/strict-mode-ladder.md` — the snippets there are fragments for
`AppServiceProvider::boot()`, not standalone files.

## Before starting

Read `ai-dev query map` for `laravel_version` and `testing`. Then:

- **`laravel_version` < 9** — `shouldBeStrict()` is unavailable. Use stage 1 only and stop.
- **`testing: none`** — stop at stage 1. Without a suite there is no cheap place to discover
  violations, and stage 2+ will surface them in someone's browser instead.

## Stage the ladder — one stage per change, never batched

Every stage is in `assets/strict-mode-ladder.md`. Paste one into
`app/Providers/AppServiceProvider::boot()`, run the full test suite, fix what it surfaces, then move
on.

1. **Stage 1 — `DB::prohibitDestructiveCommands()`.** Do this first, alone, today. Near-zero false
   positives; the only thing it can break is a pipeline that runs `migrate:fresh` against production,
   which is a finding, not a regression. Needs Laravel 11+.
2. **Stage 2 — `preventLazyLoading()` in tests only.** Every N+1 on a covered path becomes a failing
   test. Fix them with `with()`/`load()`/`withCount()`; never by loading an unbounded set into memory.
3. **Stage 3 — extend to local dev + `handleLazyLoadingViolationUsing()`** so **production logs
   instead of throwing**. This is the posture that makes strict mode survivable: telemetry in
   production, hard failure in dev/test. Skipping it is the usual reason teams adopt strict mode and
   then revert it after one incident.
4. **Stage 4 — `Model::shouldBeStrict()`**, which adds `preventSilentlyDiscardingAttributes` (mass
   assignment) and `preventAccessingMissingAttributes`.

**Stage 4 has a real tension worth naming**: `preventAccessingMissingAttributes` conflicts with
`20-database/00-query-performance.mdc`'s "select only needed columns". A project that narrows
`select()` aggressively will hit `MissingAttributeException` constantly. Stopping at stage 3 is a
legitimate end state — say so rather than forcing stage 4.

## Prove it is actually on

Presence of the call is not proof — it can sit behind a disabled env flag or an unregistered
provider. The last section of `assets/strict-mode-ladder.md` is a test asserting
`Model::preventsLazyLoading()` and friends return true — create it in the project's test suite.
`ai-dev verify` can only confirm the call appears in a provider; the test suite is what confirms the
mode is actually active.

## Do not

- Do not enable `shouldBeStrict()` in production — a lazy load becomes a 500. Guard every stage
  with `! $this->app->isProduction()`.
- Do not use `Model::automaticallyEagerLoadRelationships()` as a substitute. It *resolves* lazy
  loads instead of surfacing them, which defeats the point of the guard and can pull large relation
  sets into memory.
- Do not batch stages, and do not enable stage 2+ on a project with no test suite.
