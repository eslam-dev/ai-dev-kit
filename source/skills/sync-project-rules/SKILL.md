---
name: sync-project-rules
description: Automatically create, update, split, and clean project-specific Cursor rules after meaningful code changes.
---
# Sync Project Rules

## Trigger

Run automatically after meaningful source changes and before task completion.

## Workflow

1. Refresh the project index:
   ```bash
   ai-dev-project-index .
   ```
2. Read changed and related entries from:
   - `.ai/project-index/manifest.json`
   - `.ai/project-index/FILES.md`
   - `.ai/project-index/RELATIONS.md`
   - `.ai/project-index/ROUTES.md`
   - relevant `.ai/project-index/DOMAINS/*.md`
3. Ensure `.cursor/rules/` has the standard category structure.
4. Match affected concepts to existing rule files by scope and content.
5. Update the smallest relevant rules.
6. Create a focused new `.mdc` file when no suitable rule exists.
7. Split rules that have become too large or mixed multiple concerns.
8. Remove stale paths, symbols, routes, and relationships.
9. Verify every referenced path and symbol against the current project index.
10. Refresh the index again only if rule generation changed indexed project files.

## Naming

Use predictable names:
- `architecture-overview.mdc`
- `backend-conventions.mdc`
- `models-relationships.mdc`
- `routes-<group>.mdc`
- `frontend-<app>.mdc`
- `domain-<name>.mdc`
- `workflow-<name>.mdc`

Prefer domain and module names derived from the project itself.

## Scope

Rules must capture durable conventions and business architecture, not complete source inventories.
