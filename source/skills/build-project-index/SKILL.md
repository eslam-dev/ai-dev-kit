---
name: build-project-index
description: Create or incrementally update the project-local code intelligence index before working on the repository.
---
# Build Project Index

## Automatic usage
Run at the start of work in every repository:

```bash
ai-dev-project-index .
```

If project adapters are missing, initialize them first:

```bash
ai-dev-init .
```

## Read order (tiered — stop as soon as the work is located)
1. `.ai/project-index/PROJECT_MAP.md` — stack, domains, entry points, key files. Often enough on its own.
2. The one relevant `.ai/project-index/DOMAINS/<domain>.md`.
3. Exact symbol/route lookups: grep a single line from `.ai/project-index/SYMBOLS.jsonl` (one JSON record per file) — never read it whole.
4. On demand only: `ROUTES.md` (routing questions), `RELATIONS.md` (dependency tracing), `FILES.md` (full inventory).
5. Real source files required by the current task.

## Full rebuild
Use only for corruption, index-format upgrades, or large structural reorganizations:

```bash
ai-dev-project-index . --full
```

## Completion
After meaningful source changes:

```bash
ai-dev-project-index .
```
