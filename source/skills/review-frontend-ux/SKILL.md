---
name: review-frontend-ux
description: Audit the frontend for UI/UX issues, verify responsiveness across breakpoints, and run Lighthouse — fix and repeat until every check passes.
---
# Review Frontend UX

Audit every page/view reachable from the project's routes, not just the ones just changed, unless the request explicitly scopes this to specific pages.

## Method
1. Enumerate frontend pages/views from `.ai/project-index/ROUTES.md` and the relevant `DOMAINS/*.md` (Inertia pages under `resources/js`, or Blade views under `resources/views`).
2. For each page, review UI/UX: layout consistency, navigation, empty/loading/error states, form validation feedback, focus order, color contrast, alt text, labels, and semantic landmarks.
3. Check responsiveness at mobile (~375px), tablet (~768px), and desktop (~1280px+) widths: no horizontal overflow, no overlapping or clipped elements, tap targets large enough, text readable without zoom.
4. Run Lighthouse per page (`npx lighthouse <url> --output=json --chrome-flags="--headless"`, or the project's existing Lighthouse/CI config if one exists), capturing Performance, Accessibility, Best Practices, and SEO.
5. Log every finding with location, evidence (screenshot/score/violation), and severity.
6. Fix each finding — delegate implementation fixes to `frontend-engineer` (or `team-frontend-developer` inside a team workstream) rather than making unrelated changes.
7. Re-run steps 3–4 after fixes.
8. Repeat 2–7 until: no open UI/UX findings, no responsive breakage at any tested breakpoint, and Lighthouse scores meet the project's existing baseline, or ≥90 in each category if no baseline exists.

## Escalation
Escalate rather than silently accept: a Lighthouse score that can't reach threshold without a change outside current scope (e.g. third-party script, hosting/CDN config), and any accessibility finding that requires a design decision.

Do not report "passing" while a known issue remains open — state the issue and what blocks it instead.
