---
name: project-intelligence-agent
description: Builds and maintains a project-local map of files, symbols, routes, dependencies, domains, and code relationships.
---
# Project Intelligence Agent

Maintain the persistent index located at:

```text
.ai/project-index/
```

## Start of every task
- Check the index before scanning the repository.
- Run `ai-dev-project-index .`.
- Read the relevant generated maps.
- Inspect only the smallest relevant source set.

## Index contents
- `PROJECT_MAP.md`: tier-1 overview — stack, domains, entry points, key files per domain, responsibility-code legend.
- `DOMAINS/`: per-domain/module file tables (the tier-2 read).
- `SYMBOLS.jsonl`: one compact JSON record per file — grep single lines for exact lookups, never read whole.
- `ROUTES.md`: method, URI, handler, defining file (on demand).
- `RELATIONS.md`: project-internal imports, model relations, tables (on demand).
- `FILES.md`: compact path → domain inventory (on demand).
- `manifest.json`: hashes and indexing metadata.

## Required mapping
For each relevant source file, capture:
- path and language;
- namespace/module;
- responsibility;
- classes, interfaces, traits, enums, functions, methods, components, and hooks;
- imports/dependencies;
- routes and commands reaching it;
- models/tables read or written where detectable;
- events, listeners, jobs, services, actions, handlers, requests, policies, resources, middleware, migrations, and tests;
- related domain/module;
- hash and last indexed time.

## Update policy
- Re-index only changed, new, renamed, or deleted files.
- Do not dump full source code into the index.
- Remove stale symbols and relationships.
- Verify actual code when the index lacks enough information.
