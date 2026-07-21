---
name: optimize-query
description: Eliminate N+1 queries and optimize Laravel database access without changing behavior.
---
# Optimize Query
1. Identify the endpoint, job, command, Resource, export, or workflow.
2. Inspect the current query pattern and expected data volume.
3. Search for queries and relationship access inside loops, Resources, accessors, policies, and nested calls.
4. List relationships and aggregates used during iteration or serialization.
5. Replace per-row queries with eager loading, `withCount`, `withExists`, aggregate subqueries, joins, or batch lookups.
6. Select required columns while preserving relation keys.
7. Use pagination, `chunkById`, `lazyById`, or queues for unbounded data.
8. Review indexes and execution plans for material queries.
9. Compare query count for one record and many records; it must remain bounded.
10. Add a regression test or query-count assertion for high-risk paths.
11. Preserve authorization, tenancy, ordering, filters, response shape, and business behavior.

## Prohibited
- No queries inside loops.
- No lazy loading during serialization.
- No relation `count()` call per item.
- No accessor or appended attribute that queries per model.
- No loading an unbounded table merely to reduce query count.
- No caching used to conceal a structurally incorrect query pattern.
