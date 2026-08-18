# AI Dev Kit — Project Index First

AI Dev Kit is a global, editor-agnostic AI coding toolkit built for PHP engineering —
Laravel (Blade, Livewire, Inertia + React, Filament) first, WordPress/WooCommerce and generic
modern PHP (Symfony, plain Composer) close behind. It installs once on your machine, then, for
every project you work on, it:

1. builds and maintains a persistent, local **Project Intelligence Index** describing the codebase
   (files, symbols with line numbers, routes, hooks, schema, relationships, domains);
2. generates and maintains **project rules** in one shared place, `.ai/rules/` (security,
   performance, architecture, testing, and more), seeded from a curated template library gated by
   the *detected stack* and then evolved per project — **one rule set, never a copy per editor**;
3. wires the same workflow into whichever AI tool you're using — Cursor, Kilo, Windsurf/Devin,
   Claude Code, VS Code + GitHub Copilot, Antigravity, Roo, Cline, Continue, Trae, Junie, Zed,
   Gemini CLI, Aider, any runner that reads `AGENTS.md`, and Specify/spec-kit — so every tool
   reads the same index and the same rules instead of re-discovering the codebase on every task;
4. **keeps itself up to date inside every project**: when you upgrade the kit, the next plain
   `ai-dev .` in any project automatically refreshes every kit-managed file, without ever touching
   your customizations.

It also ships 21 specialized agents and 30 skills for the day-to-day PHP engineering workflow.

## Why

Without a persistent index, an AI coding tool has to re-explore a codebase's structure, routes, and
conventions on every single task — burning time and context, and often missing project-specific
conventions entirely. AI Dev Kit builds that map once, keeps it updated incrementally, and gives
every connected tool a cheap lookup command (`ai-dev query`) plus a tiered reading protocol so the
model loads the minimum context that answers the question.

## Install

Supported on **macOS and Linux** — every script targets bash 3.2+ (macOS's stock `/bin/bash`) and POSIX/BSD
command behavior, not GNU-only flags. Requires `python3` and `bash`.

```bash
chmod +x install.sh uninstall.sh doctor.sh
./install.sh
```

That's it — no further setup. This installs globally:
- **Commands** → symlinked into `~/.local/bin`: `ai-dev`, `ai-dev-init`, `ai-dev-project-index`,
  `ai-dev-project-rules`, `ai-dev-query`. Their real implementation, the curated rule template
  library, the spec templates, and the kit `VERSION` live under `~/.local/share/ai-dev-kit/`.
- **Agents & skills** → symlinked into `~/.cursor/agents/ai-dev-*` and `~/.cursor/skills/ai-dev-*`. Any
  pre-existing file at those paths is moved to a timestamped backup folder first, never deleted.

Make sure `~/.local/bin` is on your `PATH`. If you use Cursor, restart it to pick up the new
agents/skills.

**Optional, one-time, global**: `USER_RULES.txt` is copied to your clipboard during install. Paste it
into **Cursor Settings → Rules → User Rules** if you want its baseline applied across every project.

Re-running `./install.sh` any time is safe and idempotent. To remove everything: `./uninstall.sh`.
Health check: `./doctor.sh` (checks symlinks, commands, `python3`, the kit version, the always-on
token budget, and lints the kit's own content).

## Commands

| Command | What it does |
|---|---|
| `ai-dev .` | Init + index + rules in one step, **with automatic kit-update detection**. The only command normal use requires. |
| `ai-dev query <sub> <term>` | Side-effect-free exact lookups over the index (see below). |
| `ai-dev verify [--gates]` | Completion gate: index checks, then optionally the project's own test/analyse/lint. Exit `0` clean, `1` blocking, `2` could not run. |
| `ai-dev spec <slug>` | Scaffolds `.ai/specs/NNN-slug/{spec,plan,tasks}.md` for large (Tier L/XL) features. |
| `ai-dev update [--force] [projects...]` | Manual refresh of kit-managed files; `--force` also overwrites locally modified seeded rules. |
| `ai-dev editors` | Lists every editor adapter the kit can seed. |
| `ai-dev . --editors=kilo,windsurf` | Seeds those editors' adapters and remembers the choice in `.ai/editors`. `--all-editors` seeds them all. |
| `ai-dev-init .` | Adapter scaffolding only. |
| `ai-dev-project-index . [--full] [--runtime] [--print-stack]` | Index only. `--runtime` additionally runs `php artisan route:list --json` (opt-in — executes project code). |
| `ai-dev-project-rules . [--update] [--force]` | Rules only. |

## Versioning and auto-update

Two version numbers, never conflated:
- **Kit version** (`VERSION`, e.g. `1.4.0`) — stamped into each project at `.ai/kit-version` after a
  successful run. **Commit this file.** When the installed kit is newer than the stamp, plain
  `ai-dev .` automatically runs the update pipeline; when the stamp is newer (a teammate ran a newer
  kit), it never downgrades and prints a note to upgrade.
- **Index format version** (inside `manifest.json`) — a mismatch just rebuilds the index cache.

**Managed blocks.** Kit content in `AGENTS.md`, `CLAUDE.md`, and every editor adapter
(`.kilo/rules/…`, `.windsurf/rules/…`, `.github/copilot-instructions.md`, …)
lives between `<!-- ai-dev-kit:begin -->` / `<!-- ai-dev-kit:end -->`
markers. Updates rewrite only the block; **everything you add outside the markers is yours forever**.
Files from pre-1.4 kits are migrated automatically: pristine copies are replaced, edited ones get the
block appended below your content with a printed notice.

**Rules.** Seeded rules are tracked by content hash in `.ai/rules/.seed-manifest.json`. Updates
refresh copies you never edited, keep and list the ones you did (`kept:`), and prune rules the kit
retired (only when still pristine). `--force` overrides.

## One rule set, every editor

Rules live in exactly one place — **`.ai/rules/`** — and every tool reads that same set. Nothing is
copied per editor, so a rule you edit is a rule every agent sees.

- **Cursor** gets `.cursor/rules` as a **symlink** to `../.ai/rules` (it is the one tool that
  auto-loads a directory of `.mdc` files). Projects from kit ≤1.5 are migrated on the next
  `ai-dev .`: existing files move into `.ai/rules/` — your own and your edited ones included — and
  `.cursor/rules` becomes the symlink.
- **Every other editor** gets one small adapter file inside its own rules folder pointing at
  `AGENTS.md` and `.ai/rules/`. That file carries a managed block, so anything you add outside the
  markers is preserved.

Adapters are seeded for editors the project already uses (detected from their config directory).
Add more explicitly, once — the choice is remembered in `.ai/editors`:

```bash
ai-dev . --editors=kilo,windsurf     # or --all-editors
ai-dev editors                       # list every supported adapter
```

| Editor | Adapter | Detected via |
|---|---|---|
| Kilo Code | `.kilo/rules/00-ai-dev-kit.md` (+ `kilo.jsonc` `instructions`) | `.kilo/`, `kilo.jsonc` |
| Kilo Code (legacy) | `.kilocode/rules/00-ai-dev-kit.md` | `.kilocode/` |
| Windsurf | `.windsurf/rules/ai-dev-kit.md` | `.windsurf/`, `.windsurfrules` |
| Devin Desktop | `.devin/rules/ai-dev-kit.md` | `.devin/` |
| Antigravity | `.agents/rules/ai-dev-kit.md` | `.agents/`, `.agent/` |
| Roo Code | `.roo/rules/00-ai-dev-kit.md` | `.roo/`, `.roorules` |
| Cline | `.clinerules/00-ai-dev-kit.md` (or the single `.clinerules` file) | `.clinerules` |
| Continue | `.continue/rules/ai-dev-kit.md` | `.continue/` |
| Trae | `.trae/rules/project_rules.md` | `.trae/` |
| Junie (JetBrains) | `.junie/guidelines.md` | `.junie/` |
| Zed | `.rules` | `.zed/`, `.rules` |
| Gemini CLI | `GEMINI.md` | `.gemini/`, `GEMINI.md` |
| Aider | `CONVENTIONS.md` | `.aider.conf.yml` |
| VS Code / Copilot | `.github/copilot-instructions.md` | `.github/` |
| Specify / spec-kit | `.specify/memory/project-index.md` | `.specify/` |

`AGENTS.md` (the canonical protocol) and `CLAUDE.md` are always written, which already covers Claude
Code, Codex, Amp, Jules, and anything else that reads `AGENTS.md`.

Because rules now live under `.ai/`, keep that directory in version control — ignore
`.ai/project-index/` specifically rather than all of `.ai/`. `ai-dev` warns if your `.gitignore`
excludes `.ai/`.

## Enforcement, not just advice

Rules an agent reads are advisory — it can ignore them silently. Two things in the kit are not:

**Runtime.** The `harden-runtime` skill stages Laravel's own guards into a project:
`DB::prohibitDestructiveCommands()` first, then `Model::preventLazyLoading()` in tests, then dev with
`handleLazyLoadingViolationUsing()` so production logs instead of throwing, then the full
`shouldBeStrict()`. An N+1 stops being a rule violation and becomes a failing test. The kit never
writes into `app/` and never enables this automatically on an existing codebase — turning it on
surfaces every latent violation at once, which has to be a staged decision.

**A gate.** `ai-dev verify` must pass before a change counts as done:

```bash
ai-dev verify            # index checks only — fast, no PHP, no project execution
ai-dev verify --gates    # also runs the project's own composer test/analyse/lint
ai-dev verify --json     # for hooks and CI
```

It blocks on WordPress REST routes with no `permission_callback`, Eloquent models with neither
`$fillable` nor `$guarded`, and migrations with a missing or empty `down()`; it warns when Laravel
strict mode is off. Absent tooling is reported as skipped, never as failed.

`ai-dev verify --install-hook` merges a blocking `Stop` hook into `.claude/settings.json` (opt-in;
never written by `ai-dev .`). **It covers Claude Code and Cursor only** — the other 14 adapters get
the always-on rule, which cannot be enforced mechanically. For editor-independent enforcement, wire
`ai-dev verify` into CI.

## The Project Intelligence Index

`ai-dev-project-index` creates:

```text
.ai/project-index/
├── PROJECT_MAP.md     # tier-1 read: stack, domains, entry points, quality gates, key files, legend
├── DOMAINS/            # tier-2 read: one markdown file per discovered domain/module (capped rows)
├── SYMBOLS.jsonl       # one compact JSON record per file — line numbers, owning class, attributes
├── ROUTES.md           # on demand: method, URI, name, handler (static parse or --runtime artisan)
├── SCHEMA.md           # on demand: database schema folded from migrations
├── FRAMEWORK.md        # on demand: events→listeners, policies/gates, queues, schedule
├── HOOKS.md            # on demand (WordPress): actions/filters/shortcodes/REST/CPTs — REST routes
│                       #   without permission_callback are flagged for audit
├── RELATIONS.md        # on demand: project-internal imports, Eloquent/Doctrine relations, tables
├── FILES.md            # on demand: compact path → domain inventory
└── manifest.json       # per-file SHA-256 hashes + the detected stack object
```

**Stack detection** (persisted in `manifest.json["stack"]`, printable via `--print-stack`): Laravel,
Livewire, Filament, Horizon, Inertia, Blade, Sanctum/Passport, tenancy packages, Symfony, WordPress
(site / plugin repo / theme repo, block themes, WooCommerce), Pest/PHPUnit, PHPStan/Larastan/Psalm,
Pint/PHP-CS-Fixer, composer scripts, PSR-4 roots.

**Incremental by design.** SHA-256 per file; unchanged files are reused, ignored directories
(`vendor/`, `node_modules/` — at any depth — `.git/`, WP core, build output) are pruned during the
walk. **Deterministic output**: no timestamps, no machine paths — safe to commit and share.

Full rebuild: `ai-dev-project-index . --full`.

## `ai-dev query` — tier-0 lookups

One cheap command instead of a read chain:

```bash
ai-dev query map                        # stack + tooling + domains, ultra-compact
ai-dev query symbol UserController      # path:line, kind, visibility, owning class, attributes
ai-dev query api RefundService          # every public signature + line range + summary — no bodies
ai-dev query snippet RefundService::refund   # only the lines that symbol occupies
ai-dev query callers OrderService::refund    # every file that calls it (edit impact)
ai-dev query route orders               # matching routes with names and handlers
ai-dev query hook rest                  # WordPress hooks/CPTs/REST routes
ai-dev query file app/Models/Order.php  # one file's full brief (symbols, relations, tests)
ai-dev query domain Billing             # key files, routes, tables, tests of one domain
ai-dev query table orders               # columns (from migrations) + files touching the table
ai-dev query env STRIPE_KEY             # files using an env/config key
```

All subcommands accept `--json`, `--limit N`, `--project PATH`. Query never writes anything.

### The declaration layer

The index stores a full signature, an exact line range, and the docblock summary for every symbol, so an agent can learn **how to call** code and **where to edit** it without opening a file:

```text
RefundService::refund(Order $order, ?int $cents = null, bool $notify = true): RefundResult
  [app/Services/RefundService.php:13-20] — Refunds an order and emits the OrderRefunded event.
```

Measured on a 60-method class: reading the file costs ~3,095 tokens; `ai-dev query snippet` costs ~104 (**97% less**), and `ai-dev query api` describes the entire class for ~767.

Structural scanning runs on a string/comment-masked copy of the source, so a `}` inside a string or a `;` inside a comment cannot corrupt a range — most of an AST parser's reliability without requiring PHP to be installed.

## MCP server

Register the index once and lookups become native tool calls in your editor instead of shell commands, with the parsed index kept warm between calls:

```bash
claude mcp add ai-dev -- ai-dev-mcp --project .
```

Cursor — `.cursor/mcp.json`:

```json
{"mcpServers": {"ai-dev": {"command": "ai-dev-mcp", "args": ["--project", "."]}}}
```

It exposes 10 read-only tools: `project_map`, `find_symbol`, `list_api`, `read_symbol`, `find_callers`, `find_route`, `find_hook`, `describe_file`, `describe_domain`, `describe_table`. The tool set is deliberately small and fixed — your project's symbols are *data returned by* these tools, never one tool declaration per symbol, which would push thousands of declarations into every request and wreck both the token budget and tool-selection accuracy. The server never writes to the project and never rebuilds the index; it reports staleness and tells you to run `ai-dev .`.

## Mandatory agent behavior

Every agent working in a project is expected to:

1. Run `ai-dev .` (also applies pending kit updates).
2. Try `ai-dev query` for exact lookups (tier 0).
3. Read `PROJECT_MAP.md`, then only the relevant `DOMAINS/*.md` — stop as soon as the work is located.
4. Grep single lines from `SYMBOLS.jsonl` when query is not enough — never read it whole.
5. Open `ROUTES.md`/`SCHEMA.md`/`FRAMEWORK.md`/`HOOKS.md`/`RELATIONS.md`/`FILES.md` on demand only.
6. Open the real source when the index data is missing, stale, or sensitive; refresh after changes.

The index is explicitly **not** authoritative for security, payments, authorization, tenancy,
concurrency, migrations, destructive operations, or production incidents.

## Automatic project rule generation

`ai-dev-project-rules` seeds and maintains `.ai/rules/`, gated by the detected stack — only the
categories a project actually needs are created (a WordPress plugin gets zero Laravel rules):

```text
00-core/              # always: navigation, operating principles, minimal-change, router, maintenance
05-project-bootstrap/ # new projects & Laravel: stack decision workflow (loads only when bootstrapping)
10-laravel/           # Laravel: architecture, controllers, services, models, validation, jobs,
                      #   queues/Horizon, multi-tenancy (gated on tenancy packages)
11-php/               # any Composer project: modern PHP, PSR-4, dependency injection
12-php-tooling/       # any Composer project: quality gates; static-analysis & formatting (tool-gated)
15-inertia-react/     # Inertia detected: architecture, React+TS, UI state/performance
16-blade/             # Blade + Laravel: architecture, components/forms, view performance
17-livewire/          # Livewire: architecture, security (#[Locked], per-action authz), performance
18-filament/          # Filament: resources, authorization/tenancy, performance
20-database/          # query performance, transactions, migrations (Laravel) / non-Eloquent (others)
25-wordpress/         # WordPress: architecture, security, data/performance, REST/AJAX, frontend/assets
26-woocommerce/       # WooCommerce: HPOS-safe orders, gateways, state machine
30-api/               # Laravel: API design; Sanctum/Passport (package-gated)
40-security/          # always: secure-by-default baseline + scoped deep-dive rules
50-performance/       # Laravel: runtime/caching/Octane
60-testing/           # always: testing conventions; Pest/PHPUnit variant (runner-gated)
65-domain/            # generated per-domain overview, one folder per discovered domain
75-review/            # review protocol
```

Seeding only ever writes files that don't exist yet; from then on updates flow through the hash
manifest (see Versioning). Beyond the seed, agents evolve rules dynamically from the index — creating,
splitting, and pruning rules as the codebase changes.

## Spec-lite for large features

```bash
ai-dev spec payment-refunds
```

scaffolds `.ai/specs/001-payment-refunds/{spec.md,plan.md,tasks.md}`: `[NEEDS CLARIFICATION: …]`
markers force unknowns into one batched question round instead of silent assumptions; plan gates
check simplicity and framework-direct usage; tasks use the `[ID] [P] [Story]` grammar with exact
file paths and a blocking Foundational phase. Reserved for Tier L/XL work — small fixes skip it.

## Agents & skills

21 agents: task routing, Laravel architecture, backend/frontend/database/security engineering,
**WordPress engineering**, testing, code review, production incidents, new-project bootstrap, project
intelligence/rule maintenance, and a scaled team hierarchy (`cto`, `team-lead`,
`team-frontend-developer`, `team-backend-developer`, `team-tester`, `team-ui-ux-reviewer`).

30 skills, including: bootstrapping Laravel apps (Blade or Inertia decided per request), building
APIs, Blade views, Inertia pages, **Livewire components, Filament resources, WordPress plugins and
blocks**, designing databases and migrations, authorizing resources, webhooks and payment flows,
query optimization, writing tests, **setting up quality tooling (Pint/PHPStan/Pest with copyable
config assets)**, security audits (with a WordPress-specific audit loop), pull requests, releases,
frontend UI/UX review, project index/rule sync, and standing up a scaled team.

Several skills ship `assets/` — real files (plugin boilerplate, `pint.json`, `phpstan.neon`) that are
**copied, not generated**: zero tokens, zero drift.

## Kit development

- `tools/measure-context.py [project|--templates]` — always-on token measurement with a budget gate.
- `tools/lint_kit.py` — frontmatter validity, skill name↔directory identity, trigger-style
  descriptions, dangling skill/agent references.
- Both run inside `./doctor.sh`.
