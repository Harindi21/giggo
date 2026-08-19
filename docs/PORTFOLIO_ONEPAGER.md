# GIGGO — Smart Service Marketplace (Portfolio One-Pager)

**Role:** Tech Lead / Full-stack + ML · **Type:** Final-year thesis, rebuilt to
production standards · **Region:** Sri Lanka

---

## The product
A two-sided marketplace connecting customers with trusted local service
professionals (plumbing, electrical, moving, lifestyle, vehicle, and more). The
trust and discovery layers are driven by **five AI/ML components**; the whole
journey works end-to-end from both the customer and provider apps.

**Customer:** discover → *recommended for you* → book (live price) → track live →
pay via escrow → review. **Provider:** receive requests → accept → en route →
start → complete → get paid.

## Architecture
Monorepo, three services:
- **Flutter** app (Riverpod, GoRouter, Dio) — customer + provider, one role-aware UI.
- **Spring Boot** API (Java 21, JWT, JPA, Flyway) — domain-driven modules.
- **FastAPI** ML service (Python) — sentiment + recommender.
- **PostgreSQL** (23 Flyway migrations) + **Redis**; real-time via **STOMP/WebSocket**.

Every paid external dependency (PayHere, FCM, RoBERTa, LightFM) sits behind an
**adapter with a working stub default**, selected by config — the system runs
fully with **zero paid API keys** (maps use keyless **OpenStreetMap**), and
swapping in a real provider is a one-line change.

## AI / ML (4 of 5 built; #4 is Phase-2 by design)
1. **Multilingual review sentiment** — VADER + optional RoBERTa, with a
   **Sinhala/Singlish** path and blending for mixed text.
2. **Bayesian composite rating** — star + text-sentiment blend, shrinkage prior
   so low-review providers aren't over-ranked.
3. **Hybrid recommender** — collaborative filtering + content + quality +
   proximity, with graceful cold-start.
4. **Demand forecasting** — *Phase 2 (seam in place).*
5. **Fair ranking** — regional-diversity post-processor for equitable exposure.

## Selected engineering
- **Booking lifecycle** state machine with an auditable status timeline, plus
  disputes, rule-based **anti-fraud guards**, and a **receipt/invoice**.
- **Escrow payments** (capture → hold → release, platform-commission split),
  reused for the Tool Marketplace's direct-sale orders.
- **Real-time tracking** — JWT-authenticated WebSocket, consent-gated location,
  Haversine ETA, on a live **OpenStreetMap**.
- **Event-driven notifications** — after-commit, per-recipient, push seam, with
  in-app device-token registration.
- **Two-sided by design** — provider self-service profile (rates, service area,
  skills, availability), KYC verification, and an admin console (KYC, disputes,
  review moderation).
- **Process** — one task per branch → PR → merge; conventional commits; ~120
  backend + 42 Flutter + 21 ML tests (incl. a full-context Testcontainers run);
  DB migrations only (no drift); fail-soft cross-service calls; **9 ADRs**.

## Tech stack
`Flutter` · `Riverpod` · `Dart` · `Java 21` · `Spring Boot` · `Spring Security
(JWT)` · `JPA/Hibernate` · `Flyway` · `PostgreSQL` · `Redis` · `STOMP/WebSocket`
· `Python` · `FastAPI` · `VADER` · `RoBERTa (transformers)` · `Docker`

## Status
Showcase-complete: the full **P0–P13** roadmap is delivered end-to-end on both
roles — discovery + recommendation, booking + job lifecycle (expiry/cancel/refund,
disputes, receipts), live tracking, reviews/NLP + moderation, escrow payments,
notifications, provider self-service profile + KYC, admin console, Knowledge Hub,
and Tool Marketplace (with escrow-backed orders). All four app tabs are real;
~120 backend + 42 Flutter + 21 ML tests, 23 DB migrations, a full-context
Testcontainers run, all green. Remaining is post-showcase: **AI #4 demand
forecasting** (Phase 2, seam in place), real provider keys, and deeper `en`/`si`
localization — each a config-level or additive change behind an existing seam.
See [`STATUS.md`](STATUS.md) for the full breakdown, [`DEMO_SCRIPT.md`](DEMO_SCRIPT.md)
to run it, and [`TIDAC_PAPER_OUTLINE.md`](TIDAC_PAPER_OUTLINE.md) for the research framing.
