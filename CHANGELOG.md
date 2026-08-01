# Changelog

## 1.3.0

- **`ai-dev update [projects...]`**: propagates kit rule updates into already-seeded projects. Seeding now
  records a content hash per rule in `.cursor/rules/.seed-manifest.json`; `update` refreshes copies the
  project never edited, keeps and lists customized ones (`--force` overwrites those too). Accepts multiple
  project paths.
- **Destructive database operations require explicit user approval** in any environment (`DROP`, `TRUNCATE`,
  `migrate:fresh`/`refresh`/`reset`, `db:wipe`, deleting DB files, redis flushes) — enforced in
  `USER_RULES.txt`, the always-on security rule, the migrations rule, and the database-engineer agent.
- Fixed `ai-dev-project-rules` domain discovery reading the removed `SYMBOLS.json` (now reads
  `SYMBOLS.jsonl`, with legacy fallback).
- Compressed the always-loaded rules (`USER_RULES.txt`, agent/model router, new-project stack, dynamic rule
  maintenance) — same constraints, ~1,100 fewer tokens per prompt.

## 1.2.0

Token-efficiency overhaul of the project intelligence index (index format version `1.2.0`; old-format
indexes are rebuilt automatically on the next run).

- **Tiered reading workflow.** All adapter files, agents, skills, and rules now instruct tools to read
  `PROJECT_MAP.md` first, then only the one relevant `DOMAINS/*.md` — instead of reading the entire
  index (`ROUTES.md`, `RELATIONS.md`, `FILES.md`, …) on every task. Those files are now on-demand only.
  On a ~120-file benchmark project this cuts the default per-task index read by ~93%.
- **`PROJECT_MAP.md` is now a self-sufficient tier-1 summary**: stack, domains, entry points, key files
  per domain, and the responsibility-code legend.
- **`SYMBOLS.json` → `SYMBOLS.jsonl`**: one compact JSON record per file, so exact class/method/route
  lookups are a single-line `grep` instead of a whole-file read (~46% smaller on disk too). The legacy
  `SYMBOLS.json` is removed automatically. Per-record `hash`/`size` fields dropped (hashes live in
  `manifest.json`).
- **`RELATIONS.md` lists project-internal imports only** (project PHP namespaces, relative/aliased JS
  imports) — framework/vendor noise is gone (~86% smaller); full import lists remain in `SYMBOLS.jsonl`.
- **`ROUTES.md` parses routes** into `Method | URI | Handler | File` instead of embedding up to 600
  raw characters of route definition per row.
- **`FILES.md` is a compact path → domain inventory**; per-file symbols live only in `DOMAINS/*.md`
  and `SYMBOLS.jsonl` instead of being duplicated.
- **Short responsibility codes** (`ctrl`, `model`, `svc`, `migr`, …) replace repeated long phrases in
  all generated tables, with the legend emitted once in `PROJECT_MAP.md`.

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
