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
- `PROJECT_MAP.md`: architecture and project overview.
- `ROUTES.md`: routes, methods, names, middleware, handlers, and frontend destinations when detectable.
- `FILES.md`: file responsibility and symbol inventory.
- `RELATIONS.md`: imports, dependencies, model relations, and cross-file links.
- `SYMBOLS.json`: machine-readable symbols and metadata.
- `DOMAINS/`: per-domain/module summaries.
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
