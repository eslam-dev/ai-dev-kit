# Query-count regression test

The evidence `20-database/00-query-performance.mdc` demands — *"the query count must stay bounded as
result size grows"* — and that nothing in the kit used to produce.

**The point is not the absolute number.** It is that the count does *not* grow with the row count:
seed 1 record, seed 10, assert the same bound holds. That is what distinguishes an N+1 from a query
that is merely chatty.

Create as `tests/Feature/OrderQueryCountTest.php` (rename to the path under test) and adapt the
model, factory, and route.

```php
<?php

use App\Models\Order;
use Illuminate\Support\Facades\DB;

function queryCountFor(callable $work): int
{
    DB::flushQueryLog();
    DB::enableQueryLog();

    $work();

    $count = count(DB::getQueryLog());
    DB::disableQueryLog();

    return $count;
}

it('keeps the query count bounded as the result set grows', function () {
    $one = queryCountFor(function () {
        Order::factory()->count(1)->create();

        $this->get('/orders')->assertOk();
    });

    $many = queryCountFor(function () {
        Order::factory()->count(10)->create();

        $this->get('/orders')->assertOk();
    });

    // Identical bound for 1 row and 10 rows. If $many scales with the row count
    // the endpoint has an N+1 — fix it with with()/withCount(), never by raising
    // this number.
    expect($many)->toBe($one);
});
```

For the execution-plan half of the investigation, run `EXPLAIN` (or `EXPLAIN ANALYZE`) against the
actual query the endpoint issues — take it from the query log above, not from a guess about it.
