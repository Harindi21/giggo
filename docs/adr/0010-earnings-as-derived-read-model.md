# ADR-0010: Provider earnings as a derived read-model over payments + a payout ledger

- **Status:** Accepted
- **Date:** 2026-08-20

## Context
Providers need an earnings view (available / in-escrow / withdrawn / lifetime) and a
way to withdraw funds (P7.5/P7.6), with an admin queue to process withdrawals (P11.9).
The money truth already lives in the `payments` table: a RELEASED payment means the
provider earned its `provider_payout`; a HELD payment is escrowed but not yet earned.
A second source of truth (a mutable `balance` column) could drift from those records
whenever an update is missed, mis-ordered, or rolled back.

## Decision
Model earnings as a **derived read-model**, not a stored balance:

- **Earnings** are computed on read from the payments ledger — `lifetimeEarned` = Σ
  `provider_payout` of RELEASED payments; `inEscrow` = Σ of HELD payments.
- **Withdrawals** are the only new persisted state: a `payouts` ledger (V24) with
  `REQUESTED → PAID | REJECTED`. A REQUESTED payout reserves funds; PAID removes them;
  REJECTED returns them.
- **available = lifetimeEarned − withdrawn(PAID) − pending(REQUESTED)**, floored at 0.

Withdrawals are validated against this computed `available` at request time. There is no
balance column to keep in sync.

## Alternatives considered
- **A stored wallet balance** updated on every payment/payout event — fast to read but
  the classic dual-source-of-truth drift risk; needs careful transactional upkeep and
  reconciliation jobs. Not worth it at this scale.
- **A full double-entry ledger** (credit/debit journal) — the "correct" fintech answer
  and a clean future migration, but heavier than needed for a showcase; the payout
  table already gives an auditable withdrawal trail.

## Consequences
- Balances can never disagree with the payment records — the summary is a pure function
  of them.
- Read cost is O(payments per provider); fine here, and trivially cacheable or swappable
  for aggregate SQL (`SUM ... GROUP BY status`) if a provider ever accrues many payments.
- Payout is a **platform-managed** withdrawal (admin records the bank-transfer
  reference), consistent with the escrow model in
  [ADR-0002](0002-escrow-payments-vs-marketplace-direct-sale.md) and the addendum note
  that PayHere settles to the platform, not per-provider.
