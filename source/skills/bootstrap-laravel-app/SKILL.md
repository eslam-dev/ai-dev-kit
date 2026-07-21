---
name: bootstrap-laravel-app
description: Initialize and verify a new Laravel application, choosing Blade or the official Inertia + React + TypeScript starter kit based on the request rather than a fixed default.
---
# Bootstrap Laravel App

## Trigger
Use when the user asks to start or create a new Laravel project.

## Stack decision
Do not default to either stack. Decide per request, in this order:
1. The user explicitly names a stack (Blade, Inertia, React, SPA, "server-rendered", etc.) — use it.
2. The project already exists and has an established stack — follow it.
3. Genuinely ambiguous on a brand-new project — ask the user which they want before scaffolding.

## Procedure
1. Verify the latest stable Laravel release from official Laravel documentation.
2. Read its current PHP, extension, Composer, Node.js, and package-manager requirements.
3. Inspect the local environment.
4. Update the Laravel installer when necessary.
5. Create the new Laravel application through the official installer.
6. If Inertia + React was chosen: select the official React starter kit and TypeScript when prompted (or the current documented non-interactive equivalent), and use Inertia as provided by the starter kit.
   If Blade was chosen: use the standard Laravel application skeleton with Blade views and Vite for asset compilation.
7. Configure the requested database without committing credentials.
8. Install backend and frontend dependencies.
9. Run migrations.
10. Run the frontend/asset production build.
11. Run the initial test suite.
12. Record the installed versions, chosen frontend stack, and architectural defaults in `.cursor/project-context.md`.
13. Stop at a clean verified baseline before implementing unrelated speculative features.

## Baseline acceptance criteria
- Latest stable Laravel is installed.
- The chosen frontend stack (Blade, or the official React + Inertia + TypeScript starter kit) is present and functional.
- Application loads successfully.
- Authentication baseline works when included in the selected setup.
- Migrations run successfully.
- Frontend/asset production build succeeds.
- Tests pass.
- `.env` is ignored and `.env.example` contains placeholders only.
- No unnecessary packages were added.
