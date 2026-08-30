# Architecture Decision Records

This log captures the significant technical decisions behind GIGGO — the *why*, not
just the *what*. Each record is short, immutable once accepted, and superseded (never
edited) if a later decision changes course.

Format: lightweight [MADR](https://adr.github.io/madr/) — **Status · Context ·
Decision · Consequences**. Template: [`0000-template.md`](0000-template.md).

## Index

| # | Decision | Status |
|---|---|---|
| [0001](0001-integration-seams-with-stub-defaults.md) | External integrations behind adapter seams with stub defaults | Accepted |
| [0002](0002-escrow-payments-vs-marketplace-direct-sale.md) | Escrow for service bookings; direct sale for marketplace orders | Accepted |
| [0003](0003-stateless-ml-service.md) | Stateless ML service — backend supplies candidates + interactions | Accepted |
| [0004](0004-bayesian-composite-rating.md) | Bayesian composite rating instead of a raw star average | Accepted |
| [0005](0005-event-driven-side-effects.md) | Side effects via after-commit domain events | Accepted |
| [0006](0006-flyway-migrations-and-testcontainers.md) | Migration-only schema + full-context test on Testcontainers | Accepted |
| [0007](0007-openstreetmap-over-google-maps.md) | OpenStreetMap (flutter_map) for live tracking, not Google Maps | Accepted |
| [0008](0008-soft-hide-review-moderation.md) | Soft-hide reviews for moderation (not hard-delete) | Accepted |
| [0009](0009-rule-based-fraud-guards-at-write-points.md) | Rule-based fraud/abuse guards at write points (not an ML model) | Accepted |
| [0010](0010-earnings-as-derived-read-model.md) | Provider earnings as a derived read-model over payments + payout ledger | Accepted |
| [0011](0011-demand-forecasting-linear-trend.md) | Demand forecasting as a stateless linear-trend service (AI #4) | Accepted |
| [0012](0012-retrieval-store-for-knowledge-hub.md) | Retrieval store for the Knowledge Hub (pgvector) | Accepted |
| [0013](0013-llm-provider-seam.md) | LLM provider seam for the assistant (keyless local default) | Accepted |
| [0014](0014-rag-rollout-and-rollback.md) | Rollout and rollback for assistant prompt/model changes | Accepted |

## When to add one
Add an ADR in the same PR as a decision that a future maintainer would ask "why?"
about — a trade-off, a pattern choice, or a rejected obvious alternative. Skip it for
routine CRUD. Copy the template, take the next number, and add a row above.
