# Changelog

## 1.0.0

Initial release.

- **`ai-dev`**: a single command that initializes a project, builds/refreshes its intelligence index, and syncs its Cursor rules in one step. This is the only command normal use requires.
- **`ai-dev-init`**: scaffolds cross-tool adapters (`CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`, `.specify/memory/project-index.md`, `.cursor/rules/00-project-index-first.mdc`). Never overwrites a file that already exists, so project/team edits are preserved across re-runs.
- **`ai-dev-project-index`**: builds and incrementally updates a persistent, deterministic project intelligence index at `.ai/project-index/` — file responsibilities, classes/functions/components/hooks, routes, imports/dependencies, Eloquent relations and tables, and a domain/module breakdown. Uses SHA-256 hashing to skip unchanged files and prunes ignored directories (`vendor/`, `node_modules/`, `.git/`, build output, etc.) during the directory walk instead of after it, so it stays fast on large projects. Output contains no timestamps, git metadata, or absolute machine-specific paths, so re-running it on unchanged source produces byte-identical files regardless of which machine or user generated it — safe to commit and share across a team without spurious diffs.
- **`ai-dev-project-rules`**: creates and maintains project-specific Cursor rules under `.cursor/rules/`, seeded on first run from a curated template library (security, performance, Laravel, Inertia/React, Blade, database, API design, testing, review) gated by detected stack, then evolved dynamically per project without a fixed file-type mapping table. Seeding never overwrites a rule that already exists.
- **Frontend stack is never assumed.** Blade and Inertia + React are equally supported, equally curated Laravel frontend choices. The stack is inferred from the user's explicit request or the project's existing convention, and asked for when genuinely ambiguous on a brand-new project — never defaulted.
- **`doctor.sh`** / **`uninstall.sh`**: health check and clean removal for the global install.
- 14 specialized agents (task routing, Laravel/backend/frontend/database/security/testing engineering, production incidents, code review, project intelligence, rule maintenance, new-project bootstrap) and 25 skills covering the Laravel engineering workflow, including both Blade and Inertia + React page implementation.
- `USER_RULES.txt`: global orchestration rules covering task routing, security, performance, and index-first behavior for every project.
