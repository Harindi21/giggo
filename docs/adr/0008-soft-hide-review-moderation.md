# ADR-0008: Soft-hide reviews for moderation (not hard-delete)

- **Status:** Accepted
- **Date:** 2026-08-18

## Context
Admins need to moderate abusive or fake reviews. A hidden review must disappear from
the provider's public profile **and** stop influencing their Bayesian rating (which is
maintained incrementally via `rating_sum`/`rating_count`). Moderation decisions can be
wrong and should be auditable and reversible.

## Decision
Moderate by **soft-hiding**: a `hidden` flag (plus a `moderation_reason`) on the
review, rather than deleting the row. A hidden review is excluded from the public
listing and its contribution is **removed from the provider aggregate** (decrement
count, subtract its enhanced rating, recompute the Bayesian average). **Restore**
reverses both. Users can `report` a review (a `report_count`) to surface candidates
for an admin.

## Alternatives considered
- **Hard-delete the review** — irreversible, destroys the audit trail, and makes the
  incremental rating aggregate hard to reconcile.
- **Leave it visible but flagged** — doesn't protect the provider or readers.
- **Recompute the aggregate from scratch on every change** — simpler but O(reviews)
  per moderation; the incremental adjust is O(1) and consistent with how reviews are
  added.

## Consequences
- Moderation is reversible and auditable; the rating stays fair and consistent.
- The public review query and any rating recompute must always filter `hidden = false`.
- `report_count` has no per-user dedupe yet (a report table would add that) — fine for
  surfacing, not for hard thresholds.
