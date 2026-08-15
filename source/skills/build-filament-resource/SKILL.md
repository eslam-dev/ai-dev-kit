---
name: build-filament-resource
description: Implement a policy-integrated, tenant-scoped Filament resource with N+1-safe tables and per-record authorization.
---
# Build Filament Resource

Integrate the resource with its model policy so `viewAny`/`create`/`update`/`delete` drive what the UI shows and allows — visibility is never the control.

Requirements:
- Scoped `getEloquentQuery()` — this is the tenancy/IDOR boundary for every table row, edit page, and lookup.
- Table eager loading and `->counts()` to prevent N+1 queries.
- Form schema with validation on every field.
- Per-record authorization re-checks inside bulk actions and relation-manager actions — never trust the visible listing.
- Tests covering policy denial and query scoping.
