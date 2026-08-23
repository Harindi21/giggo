# ADR-0011: Demand forecasting as a stateless linear-trend service (AI #4)

- **Status:** Accepted
- **Date:** 2026-08-23

## Context
Providers benefit from knowing where demand is heading for their services (AI #4).
The thesis WBS frames P-level AI #4 as a forecasting model in the Python
microservice. We have real historical signal (bookings over time) but no curated,
labelled demand dataset, and the data volume per category is modest.

## Decision
Forecast demand with a **stateless least-squares linear trend** in the ML service,
fed by a **derived weekly series** the backend computes on demand:

- The backend buckets the last 8 weeks of bookings into per-category weekly counts
  (booking → skill → category), scoped to the signed-in provider's categories.
- It POSTs each series to the ML service `/api/v1/forecast`, which returns the next
  period(s) plus a trend label (rising / falling / steady). This keeps the ML
  service stateless — the backend owns the data, consistent with
  [ADR-0003](0003-stateless-ml-service.md).
- If the ML service is unavailable, the backend falls back to a naive in-process
  projection (recent average + first-half vs second-half trend), so the feature
  degrades rather than fails — same fail-soft posture as the recommender
  ([ADR-0001](0001-integration-seams-with-stub-defaults.md)).

## Alternatives considered
- **ARIMA / Prophet** — the "textbook" choice, but heavyweight dependencies and
  overkill for short, low-volume weekly series; they can replace the current method
  behind the unchanged `/forecast` contract when data justifies it.
- **Compute the trend entirely in Java** — no ML service round-trip, but it would
  drop the microservice seam the thesis calls for and make swapping in a real model
  a bigger change.
- **Precompute/store forecasts** — needless; the series is cheap to derive on read
  and always reflects the latest bookings (same read-model reasoning as
  [ADR-0010](0010-earnings-as-derived-read-model.md)).

## Consequences
- Works from day one with existing bookings; no training pipeline or labelled set.
- Honest about its power: a linear trend is a baseline, not a seasonal model —
  documented as such, with a clean upgrade path.
- Read cost is O(bookings in the last 8 weeks); fine at this scale, cacheable later.
