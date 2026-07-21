# AI Dev Kit — Project Index First

AI Dev Kit is a global Cursor / Claude Code / VS Code (Copilot) toolkit built for Laravel + Inertia/React
engineering. It installs once on your machine, then, for every project you work on, it:

1. builds and maintains a persistent, local **Project Intelligence Index** describing the codebase
   (files, symbols, routes, relationships, domains);
2. generates and maintains **project-specific Cursor rules** (security, performance, architecture,
   testing, and more), seeded from a curated template library and then evolved per project;
3. wires the same workflow into whichever AI tool you're using — Cursor, VS Code + GitHub Copilot,
   Claude Code, generic agent runners that read `AGENTS.md`, and Specify/spec-kit — so every tool reads
   the same index and rules instead of re-discovering the codebase from scratch on every task.

It also ships 20 specialized agents and 27 skills for the day-to-day Laravel/Inertia/React engineering
workflow (routing tasks, backend/frontend/database/security engineering, testing, code review,
production incidents, new-project bootstrap, project intelligence/rule maintenance, frontend UI/UX and
Lighthouse auditing, and — for large backlogs — a scaled team hierarchy of team leads, frontend/backend
developers, and testers under an optional CTO).

## Why

Without a persistent index, an AI coding tool has to re-explore a codebase's structure, routes, and
conventions on every single task — burning time and context, and often missing project-specific
conventions entirely. AI Dev Kit builds that map once, keeps it updated incrementally, and forces every
connected tool to consult it before doing a broad search.

## Install

```bash
chmod +x install.sh uninstall.sh doctor.sh
./install.sh
```

This installs globally:
- **Commands** → symlinked into `~/.local/bin`: `ai-dev`, `ai-dev-init`, `ai-dev-project-index`,
  `ai-dev-project-rules`. Their real implementation and the curated rule template library live under
  `~/.local/share/ai-dev-kit/`.
- **Agents & skills** → symlinked into `~/.cursor/agents/ai-dev-*` and `~/.cursor/skills/ai-dev-*`. Any
  pre-existing file at those paths is moved to a timestamped backup folder first, never deleted.
- **User Rules** → `USER_RULES.txt` is copied to your clipboard (or its path is printed if no clipboard
  tool is available). Paste it once into **Cursor Settings → Rules → User Rules**.

Make sure `~/.local/bin` is on your `PATH`, then restart Cursor and VS Code.

Re-running `./install.sh` any time is safe — it's idempotent and just re-syncs commands, agents, and
skills to the current state of this repo.

To remove everything: `./uninstall.sh`. To check that the install is healthy: `./doctor.sh`.

## Commands

| Command | What it does |
|---|---|
| `ai-dev .` | Runs the three commands below in order. The only command you need in normal use. |
| `ai-dev-init .` | Scaffolds the cross-tool adapter files (`CLAUDE.md`, `AGENTS.md`, etc.) — only creates files that don't already exist yet; never overwrites. |
| `ai-dev-project-index .` | Builds or incrementally updates `.ai/project-index/`. |
| `ai-dev-project-rules .` | Builds or updates `.cursor/rules/`. |

All three (and `ai-dev`) accept an optional project path argument, defaulting to `.`.

## What happens inside every project

At the start of a task, the global instructions tell every connected AI tool to run:

```bash
ai-dev .
```

You can also run it manually, once, in any project:

```bash
cd /path/to/project
ai-dev .
```

Every underlying step is safe to re-run as often as you like — nothing it writes is ever silently
overwritten once it exists, and the index/rules generation only touches what actually changed.

## The Project Intelligence Index

`ai-dev-project-index` creates:

```text
.ai/project-index/
├── PROJECT_MAP.md     # architecture overview, detected stack, domains, primary entry points
├── ROUTES.md           # every route found, with method and defining file
├── FILES.md            # every indexed file: path, domain, responsibility, symbols
├── RELATIONS.md        # imports, Eloquent relations, and database tables per file
├── SYMBOLS.json        # the same data as structured JSON, for exact lookups
├── manifest.json       # per-file SHA-256 hashes + run stats, used for incremental updates
└── DOMAINS/             # one markdown file per discovered domain/module
```

For each relevant source file it captures:
- the file's path, language, namespace, and inferred **responsibility** (controller, policy, migration,
  service, job, React page/component/hook, test, etc.);
- classes, interfaces, traits, enums, functions, methods, and React components/hooks;
- imports/dependencies;
- routes defined in the file, and Eloquent relations/tables it references;
- the domain/module it belongs to (inferred from Laravel `app/Domain(s)`/`Modules` conventions, or
  `resources/js/{pages,features,modules}` on the frontend).

**Incremental by design.** Each file's SHA-256 hash is stored in `manifest.json`; on the next run, any
file whose hash hasn't changed is reused from the previous index instead of being re-parsed. This keeps
the index cheap to refresh even on large codebases. The directory walk itself also skips `vendor/`,
`node_modules/`, `.git/`, build/cache output, etc. *during* traversal (not after), so those directories
are never even opened.

**Deterministic output.** The index contains no timestamps, no git metadata (branch/commit/changed
files), and no absolute machine-specific paths — re-running it against unchanged source produces
byte-identical files regardless of who generated it or where the project lives on disk, so committing
the index folder to your repo and sharing it across a team doesn't create noise or merge conflicts on
every regeneration.

Full rebuild (ignores the manifest and re-parses every file):

```bash
ai-dev-project-index . --full
```

## Tool integration

`ai-dev .` (or `ai-dev-init .` alone) creates these adapter files inside the project:

```text
.cursor/rules/00-project-index-first.mdc
.github/copilot-instructions.md
CLAUDE.md
AGENTS.md
.specify/memory/project-index.md
```

Each one tells its respective tool the same thing: check the index before broad exploration, read
`PROJECT_MAP.md` / `ROUTES.md` / `RELATIONS.md` / the relevant domain map first, open real source files
only when the index is missing, stale, uncertain, sensitive, or about to be modified, and refresh the
index after making changes. So the same workflow works across:

- Cursor
- VS Code + GitHub Copilot
- Claude Code
- Any agent runner that reads `AGENTS.md`
- Specify/spec-kit, via `.specify/memory/project-index.md`

None of these files are ever overwritten once created — if you or your team customize them, those edits
survive every future `ai-dev` run.

## Mandatory agent behavior

Every agent working in a project is expected to:

1. Run `ai-dev .`.
2. Read the index before searching broadly.
3. Use it to narrow down to the smallest relevant set of files.
4. Open the real source when the index data is missing, stale, or sensitive.
5. Refresh the index after making changes.

The index is explicitly **not** treated as authoritative for security, payments, authorization, tenancy,
concurrency, migrations, destructive operations, or production incidents — those always require reading
the real source.

## Automatic project rule generation

`ai-dev-project-rules` creates and maintains project-specific Cursor rules under `.cursor/rules/`:

```text
.cursor/rules/
├── 00-core/              # index-first + rule-maintenance workflow, curated operating principles
├── 05-project-bootstrap/ # new-project stack defaults
├── 10-laravel/           # curated, seeded only when `artisan` is present
├── 15-inertia-react/     # curated, seeded only when `resources/js` is present
├── 16-blade/             # curated, seeded only when `resources/views` is present
├── 20-database/          # curated, seeded only when `artisan` is present
├── 30-api/               # curated API design conventions
├── 40-security/          # curated secure-by-default baseline (always seeded)
├── 50-performance/       # curated runtime/caching/Octane rules (Laravel projects)
├── 60-testing/           # curated testing conventions
├── 65-domain/            # generated per-domain overview, one folder per discovered domain
├── 70-workflows/         # reserved scaffold for future dynamic workflow rules
├── 75-review/            # curated review protocol
└── 90-project/           # curated project-context placeholder
```

**Seeding.** On first run, each category is seeded from a curated template library at
`source/project-rules-optional/default/` (installed to
`~/.local/share/ai-dev-kit/project-rules-optional/`), gated by the detected stack — Laravel-specific
categories only seed when `artisan` is present, the Inertia/React category only when `resources/js` is
present, the Blade category only when `resources/views` is present (both can seed together on a project
that mixes the two), and security/core/api/testing/review/project categories always seed. The frontend
stack itself is never assumed for a new project — see the `05-project-bootstrap` category, which decides
Blade vs Inertia + React from the request or existing convention instead of defaulting to either. Seeding
only ever writes files that don't already exist yet.

**Ownership.** Once a rule exists inside a project, it belongs to that project. From then on it's
edited, split, or removed by the dynamic maintenance flow below — never silently overwritten by a
re-run of `ai-dev-project-rules`.

**Beyond the initial seed**, the system does not use a fixed table mapping file types to rule files.
Instead, on every run it:
- inspects changed files and indexed symbols;
- determines the affected architecture and business concepts;
- updates the smallest matching rules;
- creates new rules when none exist yet;
- splits large rules by domain/module/app/route group/workflow;
- removes stale references after deletes and renames.

Agents are instructed to run this automatically, so normal use never requires typing
`ai-dev-project-rules` by hand.

## Agents & skills

20 specialized agents cover: task routing, Laravel architecture, backend/frontend/database/security
engineering, testing, code review, production incidents, new-project bootstrap, the project
intelligence/rule maintenance system itself, and a scaled team hierarchy (`cto`, `team-lead`,
`team-frontend-developer`, `team-backend-developer`, `team-tester`, `team-ui-ux-reviewer`) for large,
multi-workstream backlogs.

27 skills cover the concrete day-to-day workflow: bootstrapping a new Laravel project (Blade or Inertia +
React, decided per request), building APIs, Blade views, and Inertia pages, designing databases and
migrations, authorizing resources, handling webhooks and payments, investigating N+1 queries, optimizing
queries, writing tests, preparing pull requests and releases, security audits, keeping the project index
and rules in sync, auditing frontend UI/UX and Lighthouse scores (`review-frontend-ux`), and standing up a
scaled team (`run-project-team`) for large task lists.

## Health check

```bash
./doctor.sh
```

Verifies that the agent/skill symlinks in `~/.cursor/agents` and `~/.cursor/skills` aren't broken, and
that all four commands (`ai-dev`, `ai-dev-init`, `ai-dev-project-index`, `ai-dev-project-rules`) resolve
on `PATH`.
