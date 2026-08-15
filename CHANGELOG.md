# Changelog

## 1.5.0

**The declaration layer** — agents now learn how to call project code, and where to edit it, without opening files. Index format `1.5.0` (rebuilds automatically).

- **Full signatures in the index.** Every PHP method/function record now carries `sig` (`(Order $order, ?int $cents = null, bool $notify = true): RefundResult`), `end` (closing line, so a symbol is an exact range not just a start), `doc` (first line of its PHPDoc), and `visibility`. Classes carry ranges and summaries too.
- **String/comment masking.** Structural scanning (body ranges, call edges, route/hook statements) now runs on a copy with string literals, `//`/`#`/`/* */` comments, and heredocs blanked out at identical offsets. A `}` inside a string or a `;` inside a comment can no longer corrupt a symbol range or truncate a route definition — most of the value of a real AST parser, without requiring PHP to be installed.
- **Call graph.** Per-file `calls` edges (`$this->m()`, `Class::m()`, `new Class()`, `$var->m()`), powering reverse lookup.
- **Three new `ai-dev query` subcommands:**
  - `api <Class|domain|path>` — the callable surface: every public method with signature, line range, and summary, no bodies.
  - `snippet <Class::method>` — only the lines that symbol occupies, with line numbers. On a 60-method class this is **~104 tokens instead of ~3,095 for the whole file (97% less)**.
  - `callers <Class::method>` — every indexed file that calls it, for edit-impact before changing a signature.
- **`ai-dev-mcp` (new command): an MCP stdio server** exposing the index as 11 native tools (`project_map`, `find_symbol`, `list_api`, `read_symbol`, `find_callers`, `find_route`, `find_hook`, `describe_file`, `describe_domain`, `describe_table`, `changed_files`). Register once and Claude Code / Cursor call lookups directly instead of shelling out; the parsed index stays warm in memory between calls and is re-read only when `SYMBOLS.jsonl` changes. Read-only — it never writes to the project and never rebuilds the index, it reports staleness.
  ```bash
  claude mcp add ai-dev -- ai-dev-mcp --project .
  ```
  Deliberately a small fixed tool set: project symbols are *data returned by* these tools, never one tool declaration per symbol (which would push thousands of declarations into every request).
- Adapter and navigation rule text updated so agents actually reach for `api`/`snippet`/`callers` instead of reading files; `ai-dev-query` now reads its supported index version from the sibling indexer so the two can never drift on a format bump.

## 1.4.0

**Auto-update.** The kit now has a version (`VERSION`, installed to `~/.local/share/ai-dev-kit/VERSION`) and every project records the kit version that last synced it in `.ai/kit-version` (commit it). Plain `ai-dev .` detects a newer installed kit and automatically refreshes all kit-managed files — no more manual `ai-dev update` after upgrading. Locally modified rules are never overwritten automatically (listed as `kept:`); a stamp newer than the installed kit never downgrades.

- **Managed blocks in adapters.** `CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`, and `.specify/memory/project-index.md` now carry kit content inside `<!-- ai-dev-kit:begin/end -->` markers. The kit rewrites only its block on updates; everything a project adds outside it is preserved forever. Pre-1.4 files are migrated on the first run: pristine kit copies (recognized by hash against every historically shipped version) are replaced; edited ones get the block appended below the project's own content with a notice.
- **`AGENTS.md` is the single canonical protocol file**; `CLAUDE.md` and the Specify adapter are now 2-line pointers to it. `.github/copilot-instructions.md` and `.specify/**` are only created when `.github/`/`.specify/` exist.
- **Seed manifest v2** (`{"schema":2,"kit_version":...,"rules":{...}}`, migrated transparently) plus **pruning**: rules retired from the kit or whose stack gate flipped off are deleted on update when still pristine.
- **`ai-dev query`** (new command, also `ai-dev query …`): side-effect-free exact lookups over the index — `symbol` (path:line + owning class + visibility + attributes), `route`, `hook`, `file`, `domain` (on-demand brief), `table` (columns from migrations), `env`, `changed` (delta since last index run), `map`. Replaces multi-file read chains with a few lines.
- **Single stack detector** (`detect_stack`) persisted in `manifest.json["stack"]` and exposed via `ai-dev-project-index --print-stack`; consumed by the rules gates. Detects Laravel, Livewire, Filament, Horizon, Inertia, Blade, Sanctum/Passport, tenancy packages, Symfony, WordPress (site / plugin repo / theme repo, block themes, WooCommerce), Pest/PHPUnit, PHPStan/Larastan/Psalm, Pint/PHP-CS-Fixer/PHPCS, composer scripts, and PSR-4 roots.
- **Index format 1.4.0** (old indexes rebuild automatically): symbols carry line numbers, owning class, visibility, PHP 8 attributes (`#[Locked]`, `#[Computed]`, …) and properties; route parser handles multi-line definitions, `Route::prefix()/name()->group()` nesting, `Route::controller()` groups, and route names; new on-demand outputs `SCHEMA.md` (schema folded from migrations), `FRAMEWORK.md` (events, policies/gates, queues, schedule), `HOOKS.md` (WordPress hooks/CPTs/REST routes — REST routes without `permission_callback` are flagged); file→test mapping (`tested_by`); env/config key inventory; delta tracking in `last-run.json`; PSR-4-aware domains for non-Laravel projects; Doctrine relations; nested `vendor/`/`node_modules` ignored at any depth; word-boundary responsibility matching (`LatestPost` is no longer a "test"); >1MB files skipped; `DOMAINS/*.md` capped at 100 rows; opt-in `--runtime` flag for `php artisan route:list --json` ground truth.
- **Stack-gated rule seeding rework** with per-file gates and new curated categories: `11-php` (modern PHP), `12-php-tooling` (quality gates, static analysis, formatting), `17-livewire`, `18-filament`, `25-wordpress` (architecture, security, data/performance, REST/AJAX, frontend/assets), `26-woocommerce` (HPOS-safe), plus `10-laravel/60-queues-horizon`, `70-multi-tenancy`, `30-api/10-sanctum`, `20-passport`, `20-database/30-non-eloquent-database`, `60-testing/10-pest`, `20-phpunit`. A WordPress or Symfony project no longer receives a single Laravel-flavored rule, and empty category directories are no longer created.
- **Always-on context cut ~58%** (~3,900 → ~1,650 tokens of always-on rules per task): the new-project bootstrap rule loads only when creating a project; the agent/model router compressed to a tier table (details moved into the `route-task` skill); five small always-on rules merged into one; security rules de-overlapped and scoped; frontend rule globs no longer attach to backend edits; `USER_RULES.txt` halved (seeded rules cover the rest). `tools/measure-context.py` measures any project and enforces a 2,000-token budget in `doctor.sh`.
- **Skills 27 → 30, agents 20 → 21**: merged 3 duplicate pairs (`investigate-n-plus-one`→`optimize-query`, `payment-integration`→`implement-payment-flow`, `update-project-rules`→`sync-project-rules`); new `wordpress-engineer` agent and `build-wp-plugin` (with copyable boilerplate assets), `build-wp-block`, `review-wp-security`, `build-livewire-component`, `build-filament-resource`, `setup-quality-tooling` (with `pint.json`/`phpstan.neon` assets) skills; `frontend-engineer`/`team-frontend-developer` now detect Blade/Livewire/Inertia/WordPress.
- **Spec-lite** for large features: `ai-dev spec <slug>` scaffolds `.ai/specs/NNN-slug/{spec,plan,tasks}.md` with `[NEEDS CLARIFICATION]` markers, simplicity/framework-direct gates, and the `[ID] [P] [Story]` task grammar (integrated into `plan-feature`).
- **Kit QA**: `tools/lint_kit.py` (frontmatter, skill name↔directory identity, trigger-style descriptions, dangling references) wired into `doctor.sh`.

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
