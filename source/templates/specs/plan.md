# Plan: {{SLUG}}

> Written after the spec has no `[NEEDS CLARIFICATION]` markers left. Consult
> `.ai/project-index/` (PROJECT_MAP.md, `ai-dev query`) and reference exact
> files and symbols — never re-explore what the index already answers.

## Approach

[The chosen approach in a few sentences, and why over the obvious alternative.]

## Affected surface

- Files/modules: [exact paths from the project index]
- Database: [migrations, tables, indexes — SCHEMA.md is the starting map]
- Routes/entry points: [from ROUTES.md / HOOKS.md]
- Authorization/security impact: [policies, gates, capabilities, tenancy]

## Gates (answer before implementation)

- Simplicity: is this the smallest complete solution? If not, why is the extra
  structure justified here?
- Framework-direct: does it use Laravel/WordPress features directly instead of
  wrapping them? Document any exception.
- Tests-first for money/auth/tenancy paths: which failing test proves each?

## Invariants and failure behavior

- [What must always hold; what happens on partial failure.]

## Risks

- [Risk → mitigation.]
