---
name: build-wp-plugin
description: Scaffold or extend a WordPress plugin from the bundled asset stubs instead of generating boilerplate.
---
# Build WP Plugin

Copy this skill's `assets/` stubs and substitute placeholders — do not regenerate boilerplate by hand:

- `assets/plugin-main.php` → `{{PLUGIN_SLUG}}/{{PLUGIN_SLUG}}.php`
- `assets/uninstall.php` → `{{PLUGIN_SLUG}}/uninstall.php`
- `assets/readme.txt` → `{{PLUGIN_SLUG}}/readme.txt`

## Placeholders
`{{PLUGIN_NAME}}` (display name), `{{PLUGIN_SLUG}}` (kebab-case; directory, main file, and text domain), `{{PLUGIN_DESCRIPTION}}`, `{{VERSION}}`, `{{AUTHOR}}`, `{{MIN_WP}}`, `{{MIN_PHP}}`, `{{TEXT_DOMAIN}}` (= `{{PLUGIN_SLUG}}`, always a literal string in i18n calls), `{{PREFIX}}` (UPPER_SNAKE for constants) and `{{prefix}}` (lower_snake for functions, options, transients, hooks, cron).

## Requirements
- Header fields complete; `Stable tag` in `readme.txt` matches the header `Version`.
- Lifecycle split: `register_activation_hook` (schema, defaults, `flush_rewrite_rules`), `register_deactivation_hook` (unschedule cron, clear transients — never delete data), `uninstall.php` (full option/table cleanup, guarded by `WP_UNINSTALL_PLUGIN`).
- Autoloading: Composer PSR-4 when `vendor/` ships with the plugin (the stub requires it if present); otherwise explicit classmap `require` statements — never include-order side effects.
- Settings API: `register_setting` with a `sanitize_callback`, `add_settings_section`/`add_settings_field`, options page behind `current_user_can` on a specific capability.
- i18n: wrap user-facing strings in `__()`/`esc_html__()` with the literal text domain; `Domain Path: /languages`.
- Prefix every function, class, option, transient, hook, and global; guard every PHP file with `defined( 'ABSPATH' ) || exit`.

## Extending an existing plugin
Consult `.ai/project-index/HOOKS.md` and `PROJECT_MAP.md` first; adopt the plugin's existing prefix, layout, and autoloading instead of the stubs.
