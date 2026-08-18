---
name: optimize-query
description: Investigate and eliminate N+1 queries and optimize Laravel database access without changing behavior.
---
# Optimize Query
1. Identify the endpoint, job, command, Resource, export, or workflow.
2. Inspect the current query pattern and expected data volume.
3. Search for queries and relationship access inside loops, Resources, accessors, policies, and nested calls.
4. List relationships and aggregates used during iteration or serialization.
5. Replace per-row queries with eager loading, `withCount`, `withExists`, aggregate subqueries, joins, or batch lookups.
6. Select required columns while preserving relation keys.
7. Use pagination, `chunkById`, `lazyById`, or queues for unbounded data; preserve memory bounds.
8. Review indexes and execution plans for material queries — run `EXPLAIN` (or `EXPLAIN ANALYZE`) on
   the actual query, not on a guess about it.
9. Prove the count is bounded, do not assert it. Wrap the path in `DB::enableQueryLog()` and compare
   the count at 1 row versus 10 rows — the two numbers must be equal. Copy
   `assets/query-count-test.md` as the starting point.
10. Leave that comparison behind as a regression test on high-risk paths.
11. Preserve authorization, tenancy, ordering, filters, response shape, and business behavior.

## Prohibited
- No queries inside loops.
- No lazy loading during serialization.
- No relation `count()` call per item.
- No accessor or appended attribute that queries per model.
- No loading an unbounded table merely to reduce query count.
- No caching used to conceal a structurally incorrect query pattern.
- No raising the expected query count to make an assertion pass.

## Prevention beats investigation

If this skill is being run repeatedly on the same project, the project is missing the runtime guard.
Run `harden-runtime`: `Model::preventLazyLoading()` turns the next N+1 into a failing test instead of
an investigation.
