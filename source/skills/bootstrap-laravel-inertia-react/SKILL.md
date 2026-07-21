---
name: bootstrap-laravel-inertia-react
description: Initialize and verify a new application using the latest stable Laravel and the official Inertia React TypeScript starter kit.
---
# Bootstrap Laravel + Inertia + React

## Trigger
Use when the user asks to start or create a new project and has not selected another technology stack.

## Procedure
1. Verify the latest stable Laravel release from official Laravel documentation.
2. Read its current PHP, extension, Composer, Node.js, and package-manager requirements.
3. Inspect the local environment.
4. Update the Laravel installer when necessary.
5. Create the new Laravel application through the official installer.
6. Choose the official React starter kit and TypeScript when prompted or use the current documented non-interactive equivalent.
7. Use Inertia as provided by the official starter kit.
8. Configure the requested database without committing credentials.
9. Install backend and frontend dependencies.
10. Run migrations.
11. Run the frontend production build.
12. Run the initial test suite.
13. Record installed versions and architectural defaults in `.cursor/project-context.md`.
14. Stop at a clean verified baseline before implementing unrelated speculative features.

## Baseline acceptance criteria
- Latest stable Laravel is installed.
- Official React + Inertia + TypeScript starter kit is present.
- Application loads successfully.
- Authentication baseline works when included in the selected official starter kit.
- Migrations run successfully.
- Frontend production build succeeds.
- Tests pass.
- `.env` is ignored and `.env.example` contains placeholders only.
- No unnecessary packages were added.
