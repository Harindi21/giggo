# ADR-0009: Rule-based fraud/abuse guards at write points (not an ML fraud model)

- **Status:** Accepted
- **Date:** 2026-08-18

## Context
A marketplace attracts predictable abuse: a customer flooding providers with bookings
they never intend to honour, someone rating their own profile, and copy-paste review
spam that skews a provider's rating. These need cheap, deterministic protection at the
moment of the write, before bad data lands and has to be cleaned up (P6.4). We have no
labelled fraud dataset, and false positives here directly block legitimate users.

## Decision
Enforce **rule-based guards inline at the service write points**, driven by config and
surfaced as normal API errors:

- **Self-booking** — reject when the booking's customer *is* the provider's user
  (`IllegalArgumentException` → 400). Already present in `BookingService.create`.
- **Open-booking throttle** — cap concurrent *open* bookings per customer
  (`REQUESTED/ACCEPTED/EN_ROUTE/STARTED`) at `giggo.fraud.max-open-bookings` (default
  20); over the cap → `TooManyRequestsException` → 429.
- **Duplicate-review-text guard** — the same customer posting identical review text on
  another job → `DuplicateResourceException` → 409, on top of the existing
  one-review-per-booking rule.

Limits live in `application.properties` (env-overridable) so they can be tuned without a
deploy. Each guard reuses an existing exception + `GlobalExceptionHandler` mapping — no
new error surface.

## Alternatives considered
- **An ML fraud/anomaly model** — no training data, opaque decisions, and heavy for the
  three concrete abuse patterns we actually have. Left behind a clean seam: these checks
  are the natural place to later call a scoring service (consistent with
  [ADR-0001](0001-integration-seams-with-stub-defaults.md) and
  [ADR-0003](0003-stateless-ml-service.md)).
- **A dedicated `FraudException` + handler** — extra surface for no gain; the abuse
  cases map cleanly onto "too many requests" (429) and "duplicate" (409).
- **Post-hoc batch detection** — lets bad data land first and needs compensating
  cleanup (refunds, rating recompute); guarding at the write point is simpler and
  immediate.
- **Rate-limit at the gateway/filter** — blunt (per-IP, not per-domain-action) and
  can't express "open bookings" or "duplicate text".

## Consequences
- Deterministic, testable, and explainable to the blocked user; limits tune via env.
- Thresholds are heuristic — the open-booking cap is deliberately generous to avoid
  blocking power users; tighten via config if abuse appears.
- The duplicate-text check is exact-match only (no fuzzy/near-duplicate detection) and
  scans by `(customer_id, body)` — cheap and good enough for copy-paste spam.
- Guards run inside the write transaction, so a rejection rolls back cleanly with no
  partial state.
