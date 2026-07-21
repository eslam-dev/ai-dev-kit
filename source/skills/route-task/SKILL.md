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

## Procedure
1. Identify whether the task is mechanical, bounded engineering, complex reasoning, or multi-specialist.
2. Count likely affected files and modules.
3. Check all risk overrides.
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
