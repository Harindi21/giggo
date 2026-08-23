# GIGGO — Build Status & Roadmap

A snapshot of what's built. The rebuild is **feature-complete for the roadmap**:
every P0–P13 task that can be built without third-party accounts is delivered on
the backend, the Flutter app, and the ML service — cross-checked task-by-task
against the 146-item WBS. Every feature follows one-task-per-branch PRs and ships
green (backend tests + `flutter analyze` + ML test suite).

## At a glance
- **3 services:** Flutter app · Spring Boot API (Java 21) · FastAPI ML service
- **Database:** PostgreSQL, **32 Flyway migrations** (schema is migration-only)
- **Tests:** ~**170 backend** unit/integration (incl. a full-context Testcontainers
  run) + **60 Flutter** + **27 ML** — all green
- **AI/ML: all 5 components live** — sentiment, Bayesian rating, recommender,
  fair ranking, demand forecasting
- **11 ADRs** capture the key architecture decisions
- **All four bottom-nav tabs are real** — no placeholder screens

## Phases

| Phase | Scope | Status |
|---|---|---|
| P0–P1 | Tooling, auth (JWT, refresh, RBAC, lockout, account deletion + export, email-OTP screen) | ✅ Done |
| P2 | Provider profiles (self-service editor + **weekly availability**) · KYC verification | ✅ Done |
| P3 | Discovery (search/detail, **nearby-providers map**) + **hybrid recommendation** (AI #3) | ✅ Done |
| P4 | Booking: pricing, state machine, expiry/cancel/refund, **disputes**, **anti-fraud**, **receipt**, **double-booking prevention** | ✅ Done |
| P5 | **Real-time tracking** (WebSocket, consent, ETA) on a live **OpenStreetMap** | ✅ Done |
| P6 | Reviews + **NLP sentiment** (AI #1), **Bayesian rating** (AI #2), **fair ranking** (AI #5), moderation, **dimension breakdown** | ✅ Done |
| P7 | **Payments + escrow** + **provider earnings/payouts** + **commission-per-category** (PayHere seam) | ✅ Done |
| P8 | **Notifications** (event-driven) + inbox + **preferences** + **delivery tracking & retry** + device tokens (FCM seam) | ✅ Done |
| P9 | **Knowledge Hub** — articles, **search**, **view-count + rating**, **profession recommendations** | ✅ Done |
| P10 | **Tool Marketplace** — catalog, **orders/checkout** (escrow), **wishlist** | ✅ Done |
| P11 | **Admin** — KYC, disputes, review moderation, **analytics dashboard**, **audit log**, **payouts**, **provider/category management** | ✅ Done |
| P12 | **Testcontainers CI** + e2e flow + **k6 500-user load test** + **NLP-accuracy eval** | ✅ Done |
| P13 | Deploy config + app-store listing prep (icons, screenshots, privacy policy) | ✅ Done |
| AI #4 | **Demand forecasting** — per-category weekly demand + next-week forecast | ✅ Done |

## AI / ML (all five live)
1. **Sentiment** — VADER + Sinhala/Singlish (RoBERTa seam) on reviews.
2. **Bayesian composite rating** — star + text blend with a shrinkage prior.
3. **Hybrid recommender** — CF + content + quality + proximity (LightFM seam).
4. **Demand forecasting** — stateless linear-trend over weekly booking series (ADR-0011).
5. **Fair ranking** — regional-diversity post-processor for equitable exposure.

## Integration seams (stub today → real for GA)

| Capability | Default (works now) | GA swap |
|---|---|---|
| Review sentiment | VADER lexicon + Sinhala | RoBERTa (`SENTIMENT_BACKEND=transformer`) |
| Recommendation | pure-Python hybrid | LightFM (`RECOMMENDER_BACKEND=lightfm`) |
| Demand forecast | linear trend + naive fallback | ARIMA/Prophet (same `/forecast` contract) |
| Maps / tracking | **live OpenStreetMap** + Haversine ETA (keyless) | routing/traffic API for turn-by-turn ETA |
| Payments | stub gateway | PayHere (`giggo.payments.gateway=payhere`) |
| Push | logging stub | FCM (`giggo.notifications.push-provider=fcm`) |
| Email / SMS | log provider | real email provider · Dialog SMS |

Every seam has a working keyless default, so nothing is blocked today; swapping in
real provider keys is a no-op wiring change (see [`adr/0001`](adr/0001-integration-seams-with-stub-defaults.md)).

## What's left — all external/operational, not codeable in-app
- **Real provider keys/accounts:** PayHere (merchant + webhooks), FCM, SendGrid /
  Dialog SMS, AWS S3 (KYC docs, portfolio images, article PDFs), Google OAuth, Sentry.
- **Operational / infra (P0.5–0.6, P13):** hosting provisioning, Cloudflare DNS +
  WAF, prod RDS/Redis, Grafana/Prometheus, Play Store submission, soft launch.
- **Human QA (P12.8):** usability testing with 10 real users.
- **i18n depth:** `en`/`si` scaffolded (ARB + delegates wired); per-screen strings +
  a language switcher remain.
- **Deferred by design:** Apple App Store / TestFlight (P13.7).

See [`DEMO_SCRIPT.md`](DEMO_SCRIPT.md) to run it, [`DEPLOYMENT.md`](DEPLOYMENT.md)
to ship it, [`STORE_LISTING.md`](STORE_LISTING.md) + [`PRIVACY_POLICY.md`](PRIVACY_POLICY.md)
for release, [`adr/`](adr/README.md) for the key architecture decisions,
[`TIDAC_PAPER_OUTLINE.md`](TIDAC_PAPER_OUTLINE.md) for the research framing, and
[`PORTFOLIO_ONEPAGER.md`](PORTFOLIO_ONEPAGER.md) for the summary.
