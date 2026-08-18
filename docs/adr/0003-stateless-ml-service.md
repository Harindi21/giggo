# ADR-0003: Stateless ML service — the backend supplies candidates + interactions

- **Status:** Accepted
- **Date:** 2026-08-15

## Context
The Python ML service performs review **sentiment** and provider **recommendation**.
Recommendation needs provider features and the customer↔provider interaction matrix.
The obvious approach — give the ML service its own database access — creates a second
source of truth, deployment coupling, and data-sync problems.

## Decision
Keep the ML service **stateless**. The Spring backend (the system of record) gathers
the inputs and **posts them to the ML service**, which computes and returns a result:
for recommendation, the backend sends candidate providers + interactions and receives
a ranked list; for sentiment, it sends the review text. The backend calls are
**fail-soft** — if ML is down, reviews still save (sentiment backfilled) and
recommendations fall back to a quality ranking.

Defaults are **pure-Python** (VADER sentiment, a hand-rolled hybrid recommender) with
optional heavy backends (RoBERTa, LightFM) behind config — see ADR-0001.

## Alternatives considered
- **ML service with its own DB** — data duplication, sync, and coupling.
- **Recommendation inside the Java backend** — mixes concerns and loses the Python ML
  ecosystem.

## Consequences
- One source of truth; the ML service scales and deploys independently and is trivial
  to test (pure functions over its inputs).
- Request payloads carry the interaction data (fine at this scale; would need paging
  or a feature store at very large scale).
- Cross-service calls must degrade gracefully — enforced by the fail-soft clients.
