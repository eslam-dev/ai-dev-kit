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

## Read order
1. `.ai/project-index/PROJECT_MAP.md`
2. `.ai/project-index/ROUTES.md`
3. `.ai/project-index/RELATIONS.md`
4. Relevant `.ai/project-index/DOMAINS/*.md`
5. `.ai/project-index/SYMBOLS.json` for exact lookup
6. Real source files required by the current task

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
