---
name: review-wp-security
description: Evidence-based WordPress/WooCommerce security audit driven by the project index and dangerous-pattern greps.
---
# Review WP Security

## Method
1. Map the surface from the index: `.ai/project-index/PROJECT_MAP.md`, then `HOOKS.md` (hooks, CPTs, AJAX handlers, REST routes).
2. Grep the index for exposed REST routes: `grep 'NO permission_callback' .ai/project-index/HOOKS.md` (fall back to `ROUTES.md`). Every hit is a finding until proven intentionally public and safe.
3. Grep source for dangerous patterns:
   - `wp_ajax_nopriv_` — unauthenticated AJAX surface; verify each handler is safe for anonymous callers.
   - `$wpdb->query(` and `$wpdb->get_*(` without `$wpdb->prepare` — SQL injection.
   - `echo $_GET` / `echo $_POST` / `echo $_REQUEST` (and unescaped request-derived variables at echo time) — XSS.
   - `admin_post_` handlers with no `check_admin_referer`/`wp_verify_nonce` — CSRF.
   - `wp_remote_get(` on user-influenced URLs — SSRF; require `wp_safe_remote_get`.
   - `unfiltered_html`, `eval(`, `base64_decode(` — privilege and obfuscation red flags.
4. Verify every state change (form handler, AJAX, REST, `admin_post_`, bulk action) has both `current_user_can()` on the specific capability and a verified nonce; a nonce never substitutes for a capability check, and `is_admin()` is never authorization.
5. Rank findings Critical, High, Medium, or Low by exploitability and impact, as in `security-audit`.
6. For each finding report location, evidence (the matched line), attack scenario, remediation, and a verification step; mark uncertain findings as requiring verification.
7. Critical and High findings block release unless explicitly risk-accepted.
