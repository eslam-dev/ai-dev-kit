---
name: setup-quality-tooling
description: Install and wire code-quality tooling (Pint, Larastan/PHPStan, Pest) into a Laravel project, respecting tooling that already exists.
---
# Setup Quality Tooling

## Detect first
Read `composer.json` (`require-dev` and `scripts`) before installing anything:
- Formatter already present (`laravel/pint` or `friendsofphp/php-cs-fixer`) — keep and configure it; do not install a competitor.
- Static analysis already present (`larastan/larastan` or `phpstan/phpstan`) — keep it.
- Test framework: respect an existing PHPUnit setup; do not convert it to Pest. Install Pest only when no framework is set up.

## Install and configure
1. Install only the missing tools as dev dependencies: `laravel/pint`, `larastan/larastan` (plain `phpstan/phpstan` outside Laravel), `pestphp/pest`.
2. Copy this skill's assets into the project as starting points — do not generate configs from scratch:
   - `assets/pint.json` → `pint.json`
   - `assets/phpstan.neon` → `phpstan.neon` (uncomment the larastan include when larastan is installed)
   Adjust paths or level only if the project clearly requires it; leave the rest for the team to evolve.
3. Wire composer scripts, keeping any that already exist: `"test"` → test runner, `"lint"` → formatter, `"analyse"` → static analysis.

## Verify
Run each tool once (`composer lint`, `composer analyse`, `composer test`) and fix configuration errors until all three execute successfully. Pre-existing findings in project code are reported, not silently fixed.
