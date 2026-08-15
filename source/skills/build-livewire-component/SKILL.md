---
name: build-livewire-component
description: Implement a secure, thin Livewire component with locked state, authorized actions, and full Livewire::test() coverage.
---
# Build Livewire Component

Keep the component thin: it wires state and presentation, delegating business logic to actions/services.

Requirements:
- `#[Locked]` on ids and any state the client must not tamper with.
- Authorization check inside every public action method — a mount-time check alone is not enough.
- Validate all bound input before using it.
- `wire:key` on every element rendered in a loop.
- `#[Computed]` for derived data instead of recomputing in the view.
- `Livewire::test()` coverage for every public action, including authorization failures.
