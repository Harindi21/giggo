# GIGGO — Conference Paper Outline (TIDAC)

A ready-to-flesh-out structure for a paper on GIGGO, framed around its AI/ML
contributions. Each section lists what to write and points at the concrete
implementation so claims stay grounded.

> **Suggested title:** *GIGGO: An AI-Augmented Service Marketplace for Sri Lanka —
> Multilingual Review Sentiment, Fair Rating and Ranking, and Hybrid
> Recommendation.*

---

## Abstract (~200 words)
Problem (fragmented, low-trust local services) → approach (a marketplace whose
trust and discovery layers are driven by five AI/ML components) → what was built
(three-service system, production-oriented) → headline results (qualitative +
the evaluations below).

## 1. Introduction
- Context: on-demand local services in Sri Lanka; trust, discoverability and
  fairness gaps.
- Contributions:
  1. A **multilingual review-sentiment** pipeline handling English **and**
     Sinhala/Singlish (romanised), degrading gracefully.
  2. A **Bayesian composite rating** that blends star + text sentiment and is
     robust to low review counts.
  3. A **hybrid recommender** (collaborative + content + quality + proximity)
     with principled cold-start behaviour.
  4. A **regional fair-ranking** post-processor for equitable provider exposure.
  5. A **real-time tracking** subsystem (WebSocket, consent-gated, ETA).

## 2. Related Work
Lexicon vs. transformer sentiment (VADER; `cardiffnlp/twitter-roberta-base-
sentiment-latest`); code-mixed/low-resource NLP (Sinhala/Singlish); Bayesian /
shrinkage rating (IMDb weighted rating); hybrid recommenders (LightFM, item-item
CF); fairness in ranking/exposure.

## 3. System Architecture
- **Monorepo, three services:** Flutter app (`mobile/`), Spring Boot API
  (`backend/`, Java 21), FastAPI ML service (`ml-service/`).
- **Data:** PostgreSQL with Flyway migrations (V1–V17); Redis.
- **Patterns:** `ApiResponse<T>` envelope; DTO records; JWT auth + role guards;
  event-driven side effects via `@TransactionalEventListener(AFTER_COMMIT)`.
- **Integration seams:** every external dependency (maps, payment gateway, push,
  transformer model, LightFM) sits behind an adapter with a working stub default,
  selected by config — so the system runs end-to-end with zero paid keys.
- *Figure:* component diagram (app ↔ backend ↔ ml-service ↔ DB).

## 4. AI/ML Methods (the core)

### 4.1 Review Sentiment (Component #1)
- Pluggable analyzer: **VADER** lexicon (default) or **RoBERTa** transformer
  (`SENTIMENT_BACKEND=transformer`); script detection routes Sinhala vs. English;
  a Sinhala/Singlish keyword analyzer handles romanised text; mixed text is
  **blended**. Output: label, score, star, confidence, emotion, language.
- *Impl:* `ml-service/app/services/sentiment/` (`service.py`, `lexicon.py`,
  `sinhala.py`, `transformer.py`).

### 4.2 Bayesian Composite Rating (Component #2)
- Enhanced per-review rating = `stars·0.6 + textStar·0.4`; provider score =
  `(n/(n+m))·rawAvg + (m/(n+m))·prior`, prior 3.0, m 5. `rating_sum` stored for
  exact recompute.
- *Impl:* `backend/.../review/service/BayesianRatingCalculator.java`; migration V15.

### 4.3 Hybrid Recommendation (Component #3)
- Item-item **collaborative filtering** (cosine on the interaction matrix) +
  **content** affinity (category/district) + **Bayesian quality** + **proximity**,
  with weights adapting from cold-start (quality/proximity) to personalised.
  Stateless service; the backend supplies candidates + interactions. LightFM
  behind a seam.
- *Impl:* `ml-service/app/services/recommender/` (`hybrid.py`); backend
  `com.giggo.backend.recommendation`.

### 4.4 Demand Forecasting (Component #4) — *future work*
- Time-series forecasting of demand by category/district to guide provider
  supply and dynamic pricing. Deferred to Phase 2; the pricing engine already
  exposes the seam.

### 4.5 Fair Ranking (Component #5)
- Post-processing re-order that guarantees the top-N results span at least a
  configurable number of districts, improving exposure equity without discarding
  relevance.
- *Impl:* `backend/.../provider/service/FairRankingReorderer.java`.

## 5. Implementation Highlights
- **Booking lifecycle** state machine (Requested → … → Completed/Paid) with
  guarded transitions and an auditable status-event timeline.
- **Real-time tracking:** STOMP/WebSocket, JWT CONNECT auth, opt-in consent gate,
  Haversine ETA (Google Maps seam).
- **Payments + escrow:** capture → hold → release with a platform-commission
  split (PayHere seam).
- **Notifications:** event-driven, per-recipient, push behind an FCM seam.
- **Engineering process:** one WBS task per branch → PR → merge; conventional
  commits; ~74 backend unit/integration tests + a Python test suite; DB via
  Flyway (17 migrations).

## 6. Evaluation (what to measure for the paper)
- **Sentiment:** accuracy/F1 on a labelled set of GIGGO-style reviews, incl. a
  Sinhala/Singlish subset; VADER vs. RoBERTa vs. blended.
- **Rating robustness:** show ranking stability vs. naïve mean under few reviews.
- **Recommendation:** offline precision@k / recall@k / MAP on held-out
  interactions; cold-start vs. warm.
- **Fair ranking:** district-exposure distribution before/after; relevance cost.
- **System:** WebSocket load test (200 connections — see `loadtest/`); API
  latency.

## 7. Discussion & Limitations
Low-resource Sinhala NLP coverage; stub gateways in the demo; offline-only
recommender evaluation; single-region assumptions.

## 8. Conclusion & Future Work
Recap contributions; Phase-2 demand forecasting; on-device/real transformer
serving; production hardening (KYC, real payment/push providers).

---

### Feature → AI/ML component map (for a table in the paper)
| Product feature | AI/ML component | Where |
|---|---|---|
| Review sentiment badges | #1 Sentiment (VADER/RoBERTa + Sinhala) | `ml-service/.../sentiment/` |
| Provider rating / sort | #2 Bayesian rating | `BayesianRatingCalculator.java` |
| "Recommended for you" | #3 Hybrid recommender | `ml-service/.../recommender/` |
| (Phase 2) supply/pricing | #4 Demand forecasting | *seam only* |
| Search result ordering | #5 Fair ranking | `FairRankingReorderer.java` |
