---
name: implement-payment-flow
description: Implement secure, idempotent payment integrations and order state transitions.
---
# Implement Payment Flow

Treat payment as an explicit state machine, separating the gateway adapter from business orchestration and provider status from internal status.

Requirements:
- Server-calculated money only, in minor currency units or decimal types — never floats, never client-supplied amounts.
- Idempotency keys and unique payment references; duplicate-request protection.
- Signature verification on every webhook/callback; never mark the business object paid solely from an unverified client redirect.
- Transaction/locking strategy for state transitions; side effects dispatched after commit.
- Immutable transaction records; safe retries and timeout handling.
- Reconciliation path against the provider.
- Adversarial tests: replayed webhooks, duplicate submissions, out-of-order events, tampered amounts.
