---
name: security-audit
description: Perform an evidence-based Laravel security audit with prioritized remediation.
---
# Security Audit
Inspect authentication, authorization, tenant isolation, IDOR, mass assignment, validation, encoding, injection, XSS, CSRF, CORS, SSRF, uploads, path traversal, secrets, logs, sensitive data, rate limits, sessions/tokens, webhooks, payments, dependencies, debug exposure, cache isolation, queues, and exports.

## Method
1. Map trust boundaries, actors, assets, tenants, integrations, and critical state transitions.
2. Trace routes from input through validation, authorization, persistence, side effects, and response.
3. Search for dangerous patterns such as `$request->all()`, unscoped `find()`, raw SQL, shell execution, public uploads, disabled TLS checks, permissive CORS, debug output, logged payloads, and unsigned callbacks.
4. Verify controls using code evidence and tests; do not assume defaults.
5. Rank findings Critical, High, Medium, or Low by exploitability and impact.
6. For each finding include location, attack scenario, affected data/flow, remediation, and a verification test.
7. Mark uncertain findings as requiring verification.
8. Critical and High findings block release unless explicitly risk-accepted.
