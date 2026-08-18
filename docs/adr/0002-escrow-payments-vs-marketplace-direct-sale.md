# ADR-0002: Escrow for service bookings; direct sale for marketplace orders

- **Status:** Accepted
- **Date:** 2026-08-15

## Context
GIGGO handles money in two very different situations: paying a **provider for a
completed job**, and buying a **tool from the marketplace**. A service is delivered
over time and can go wrong (hence disputes); a tool purchase is a simple retail
transaction. We needed a payment model for each without duplicating gateway plumbing.

## Decision
- **Bookings use escrow.** The customer pays after completion; funds are **held** by
  the platform (`PENDING → HELD`) and only **released** to the provider minus a
  commission when the customer is satisfied (`→ RELEASED`), or **refunded**
  (`→ REFUNDED`) on dispute/cancel. This protects both sides.
- **Marketplace orders are a direct sale.** No hold/release — `place → pay (PAID)`.
- Both flows **share the same `PaymentGateway` adapter** via a generic
  `initiate(amount, currency)`; only the *lifecycle* differs.

## Alternatives considered
- **Escrow for everything** — pointless ceremony and worse UX for buying a drill.
- **A single generic Payment entity for both** — conflates two lifecycles and a
  Payment-per-booking uniqueness constraint; kept as separate `Payment` (escrow) and
  `ToolOrder` (sale) aggregates instead.

## Consequences
- The right protection for each context; disputes can reverse held funds cleanly.
- The gateway seam is reused, so adopting real PayHere is one adapter for both.
- Two payment-bearing aggregates to maintain; reporting across "all money" must union
  them.
