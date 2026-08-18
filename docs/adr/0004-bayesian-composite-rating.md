# ADR-0004: Bayesian composite rating instead of a raw star average

- **Status:** Accepted
- **Date:** 2026-08-13

## Context
Provider ranking and trust depend on a rating. A naïve average of stars is unfair and
gameable: a provider with a single 5★ review would outrank a proven provider with a
4.7★ average over 200 reviews, and the written review's sentiment is ignored entirely.

## Decision
Compute a **Bayesian (shrinkage) composite rating**:
`score = (n / (n + m)) · rawAvg + (m / (n + m)) · prior`, with `prior = 3.0` and
`m = 5`. Each review's contribution blends stars with the **NLP sentiment** of its
text (`stars·0.6 + textStar·0.4`). We store `rating_sum` so the average can be
recomputed exactly, and the denormalised `avg_rating` is used for list rendering.

## Alternatives considered
- **Raw mean of stars** — unstable for low counts, ignores review text.
- **Wilson lower bound** — great for binary up/down, awkward for 1–5★ + sentiment.

## Consequences
- New providers sit near the neutral prior and climb as evidence accumulates —
  robust and hard to game with a few reviews.
- The written review actually influences the score (ties into the sentiment pipeline).
- The prior/`m` are tunable knobs (config); `rating_sum` must be maintained on every
  review for exact recomputation.
