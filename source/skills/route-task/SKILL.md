---
name: route-task
description: Classify and delegate a coding task to the smallest capable agent and model tier.
---
# Route Task

## Inputs
- User request.
- Current project context.
- Affected module and estimated blast radius.
- Security, data, financial, and production risk.

## Tier definitions
- **Tier S — Small/Fast Agent (fast/mini/low-cost model).** Renames, formatting/lint fixes, small localized bug fixes with an obvious cause, simple tests for existing behavior, straightforward validation rules, translations/comments/docs/config, simple CRUD following an existing pattern exactly, explaining a small code block, codebase search/reference collection, mechanical refactors. Constraints: usually 1–3 files; no schema change; no payment/authorization/tenant/security/concurrency/production-critical flow; no ambiguous business decision; no broad architecture change.
- **Tier M — Standard Engineering Agent (balanced coding/reasoning model).** Normal features, multi-file bug fixes, new endpoint on existing architecture, service/action extraction, query optimization with known scope, low-to-medium-risk migrations, integration with an existing internal service, moderate refactors, feature tests across several layers. Typical scope: 3–12 files, one bounded module, clear business rules, limited database/API impact.
- **Tier L — Strong Reasoning Agent (strongest approved model).** New module or cross-module architecture; unclear/conflicting business rules; complex database design; payment/financial/inventory/balance/order state machines; authentication, authorization, tenant isolation, security, privacy; race conditions, locking, idempotency, distributed workflows; high-impact performance problems; production incidents with uncertain root cause; legacy refactors with broad behavior risk; tasks touching more than ~12 files or several bounded contexts.
- **Tier XL — Lead + Specialist Team.** Only when the task spans architecture, database, security, performance, testing, and rollout; has multiple independent workstreams; is a risky production migration or critical release; root cause stays uncertain after initial investigation; or needs review by more than one specialist. Stand the team up with the `run-project-team` skill: `team-lead` per workstream (`cto` above them for multi-workstream projects), `team-frontend-developer`/`team-backend-developer` for implementation, `database-engineer` when persistence changes, `security-engineer` for trust-boundary changes, `team-tester` for regression coverage, `team-ui-ux-reviewer` for UI/UX/responsive/Lighthouse checks on frontend units, `reviewer` for final sign-off.

## Procedure
1. Identify whether the task is mechanical, bounded engineering, complex reasoning, or multi-specialist.
2. Count likely affected files and modules.
3. Check all risk overrides (see the always-on router rule) — any hit forces Tier L or XL.
4. Assign Tier S, M, L, or XL.
5. Select the primary agent.
6. Add only necessary reviewers.
7. Define escalation conditions.
8. Delegate independent subtasks only when coordination cost is lower than doing them directly.
9. After implementation, run the required review tier.

## Cost policy
- Prefer the smallest capable model.
- Use strong reasoning only for uncertainty, broad impact, or material risk.
- Move repetitive follow-up edits back to a small agent.
- Do not use multiple agents for a task one small agent can complete safely.
- Do not let cost reduction weaken correctness, security, or data integrity.
- Do not burden the user with routing details unless useful, requested, or high risk.
