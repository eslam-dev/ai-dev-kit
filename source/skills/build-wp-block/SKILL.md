---
name: build-wp-block
description: Build a Gutenberg block registered via block.json with a @wordpress/scripts build.
---
# Build WP Block

Decide dynamic vs static first: dynamic (`render` callback or `render.php`, PHP renders per request) whenever output depends on live data — queries, current user, time, settings; static (`save()` markup stored in post content) only for markup that will never change, since changing it later requires deprecations. When unsure, choose dynamic.

- Register with `register_block_type( __DIR__ . '/build/<block-name>' )` reading `block.json` (name, title, category, attributes, supports, `editorScript`/`style`/`render`). Never hand-register block assets with `wp_register_script`.
- Build with `@wordpress/scripts`: source under `src/`, `wp-scripts start`/`wp-scripts build`, register from `build/`.
- Render callbacks escape every attribute at output (`esc_html`, `esc_attr`, `esc_url`, `wp_kses_post`) and wrap output with `get_block_wrapper_attributes()`.
- Block themes: check the active theme's `theme.json` first; inherit palette, typography, and spacing through block `supports` instead of hardcoding CSS values.
- Prefix the block namespace with the project prefix and keep the text domain literal in i18n calls.
