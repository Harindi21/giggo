# ADR-0005: Side effects via after-commit domain events

- **Status:** Accepted
- **Date:** 2026-08-13

## Context
A booking status change must trigger several side effects: broadcast to the live
tracking WebSocket, and (later) create notifications. Calling these directly from
`BookingService` would couple the core lifecycle to WebSocket and notification
concerns, and risk firing side effects for a transaction that later rolls back.

## Decision
`BookingService` only publishes a `BookingStatusChangedEvent` via Spring's
`ApplicationEventPublisher`. Listeners handle the side effects with
`@TransactionalEventListener(phase = AFTER_COMMIT)`, so they run **only after the DB
commit succeeds**, and each **fails soft** (a notification error never affects the
booking). New reactions are added as new listeners, not edits to the service.

## Alternatives considered
- **Direct calls** from the service — tight coupling; side effects on rolled-back
  transactions; the service grows every time a new reaction is added.
- **An external message broker (Kafka/Rabbit)** — operationally heavy for a
  single-service monolith at this stage; in-process events suffice.

## Consequences
- `BookingService` stays focused on the lifecycle; tracking and notifications are
  decoupled and independently testable.
- Side effects are correct-by-construction w.r.t. transactions.
- In-process events don't survive a crash between commit and listener — acceptable
  now; a broker is the scale-out path if durability is required.
