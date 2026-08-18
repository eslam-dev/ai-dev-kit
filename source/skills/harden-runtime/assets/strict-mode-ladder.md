# Strict-mode ladder

Snippets to paste into `app/Providers/AppServiceProvider::boot()`, one stage per change. They are
fragments, not files — `$this` only resolves inside the provider method.

Run the full test suite after each stage and fix what it surfaces before moving to the next.

## Stage 1 — destructive commands (Laravel 11+)

Do this first, alone. Near-zero false positives: the only thing it can break is a pipeline that
already runs a destructive command against production, which is a finding rather than a regression.

```php
use Illuminate\Support\Facades\DB;

DB::prohibitDestructiveCommands($this->app->isProduction());
```

## Stage 2 — lazy loading, tests only

Every N+1 on a covered path becomes a failing test, which is the cheapest place to discover one.
Fix violations with `with()` / `load()` / `loadMissing()` / `withCount()` — never by loading an
unbounded set into memory, and never by deleting the assertion.

```php
use Illuminate\Database\Eloquent\Model;

Model::preventLazyLoading($this->app->runningUnitTests());
```

## Stage 3 — lazy loading in dev, logging in production

The `handleLazyLoadingViolationUsing` half is what makes strict mode survivable: a missed N+1
becomes telemetry in production, never a 500. Teams that skip it are the ones who adopt strict mode
and revert it after the first incident.

```php
use Illuminate\Database\Eloquent\LazyLoadingViolationException;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Log;

Model::preventLazyLoading(! $this->app->isProduction());

Model::handleLazyLoadingViolationUsing(function (Model $model, string $relation): void {
    if (app()->isProduction()) {
        Log::warning('Lazy loading violation', [
            'model' => $model::class,
            'relation' => $relation,
        ]);

        return;
    }

    throw new LazyLoadingViolationException($model, $relation);
});
```

## Stage 4 — the full bundle

`shouldBeStrict()` enables all three guards: `preventLazyLoading` (N+1),
`preventSilentlyDiscardingAttributes` (mass assignment), and `preventAccessingMissingAttributes`
(reading a column you did not select).

Decide before applying: the third guard conflicts with `20-database/00-query-performance.mdc`'s
"select only needed columns". A project that narrows `select()` aggressively will hit
`MissingAttributeException` constantly. **Stopping at stage 3 is a legitimate end state.**

```php
use Illuminate\Database\Eloquent\Model;

Model::shouldBeStrict(! $this->app->isProduction());
```

## Proof that the guards are on

Presence of the call is not proof — it can sit behind a disabled env flag, an unregistered provider,
or dead code. `ai-dev verify` can only confirm the call exists; this test confirms the mode is
active. Create it as `tests/Feature/StrictModeTest.php` and enable one expectation per stage.

```php
<?php

use Illuminate\Database\Eloquent\Model;

it('prevents lazy loading', function () {
    expect(Model::preventsLazyLoading())->toBeTrue();
});

it('prevents silently discarding attributes', function () {
    expect(Model::preventsSilentlyDiscardingAttributes())->toBeTrue();
})->skip('enable at stage 4');

it('prevents accessing missing attributes', function () {
    expect(Model::preventsAccessingMissingAttributes())->toBeTrue();
})->skip('enable at stage 4, only if the project does not narrow select() lists');
```
