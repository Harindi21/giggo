# GIGGO — Deployment Guide

How to deploy the three services. Everything runs with stub adapters and no paid
keys; for production, set the real values in the environment tables below — each
is a config-level swap behind an existing seam (no code change).

Recommended shape: **backend** + **ml-service** as containers on a PaaS
(Render / Railway / Fly.io / any container host), **PostgreSQL** as a managed
database, and the **Flutter app** built for the Play Store / App Store.

---

## 1. Database

Provision a managed PostgreSQL 15+ instance. Nothing else to do: **Flyway runs
all migrations automatically on backend startup** (`spring.flyway.enabled=true`),
and `spring.jpa.hibernate.ddl-auto=validate` guards the mapping. The full
migrate-from-scratch path is covered by the Testcontainers context test (P12).

## 2. Backend (Spring Boot, Java 21)

Container image is defined in [`backend/Dockerfile`](../backend/Dockerfile)
(multi-stage Maven build → JRE runtime, exposes 8080).

```bash
docker build -t giggo-backend ./backend
docker run -p 8080:8080 --env-file backend.env giggo-backend
```

### Backend environment

| Variable | Purpose | Default (dev) |
|---|---|---|
| `SPRING_DATASOURCE_URL` | JDBC URL of the managed DB | local 5433 |
| `SPRING_DATASOURCE_USERNAME` / `SPRING_DATASOURCE_PASSWORD` | DB credentials | `giggo` |
| `PORT` | HTTP port | `8080` |
| `JWT_SECRET` | **Required in prod** — Base64 signing secret | dev placeholder |
| `JWT_EXPIRATION_MINUTES` / `JWT_REFRESH_EXPIRATION_DAYS` | token lifetimes | 15 / 30 |
| `ML_BASE_URL` | ML service base URL | `http://localhost:8000` |
| `ML_API_KEY` | shared key sent as `X-API-Key` | `local-dev-key` |
| `PAYMENTS_GATEWAY` | `stub` or `payhere` | `stub` |
| `PAYMENTS_COMMISSION_RATE` | platform cut (0–1) | `0.10` |
| `NOTIFICATIONS_PUSH_PROVIDER` | `stub` or `fcm` | `stub` |
| `EMAIL_PROVIDER` | `log` or a real provider | `log` |
| `SENTRY_DSN` / `SENTRY_ENV` | error monitoring (optional) | empty |
| `SEED_DEMO_DATA` | seed demo providers — **never true in prod** | `false` |

> Spring Boot maps these env vars onto its properties via relaxed binding, so no
> code change is needed to point at a production database or flip a seam.

## 3. ML service (FastAPI, Python)

Container image in [`ml-service/Dockerfile`](../ml-service/Dockerfile) (default,
lexicon sentiment + hybrid recommender). A heavier image with the RoBERTa model
lives in `ml-service/Dockerfile.transformer`.

```bash
docker build -t giggo-ml ./ml-service
docker run -p 8000:8000 -e API_KEY=... giggo-ml
```

| Variable | Purpose | Default |
|---|---|---|
| `API_KEY` | must match the backend's `ML_API_KEY` | `local-dev-key` |
| `SENTIMENT_BACKEND` | `lexicon` or `transformer` (needs `requirements-transformer.txt`) | `lexicon` |
| `RECOMMENDER_BACKEND` | `hybrid` or `lightfm` (needs `requirements-lightfm.txt`) | `hybrid` |
| `ENVIRONMENT` | label | `local` |

Health check: `GET /health` → `{"status":"ok"}`.

## 4. Mobile (Flutter)

Point the app at the deployed API at build time:

```bash
cd mobile
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://api.your-domain.com   # Android (Play Store)
flutter build ipa --release \
  --dart-define=API_BASE_URL=https://api.your-domain.com   # iOS (App Store)
```

See [STORE_LISTING.md](STORE_LISTING.md) for listing content and
[PRIVACY_POLICY.md](PRIVACY_POLICY.md) for the required privacy policy.

## 5. Go-live checklist

- [ ] Managed Postgres provisioned; `SPRING_DATASOURCE_*` set
- [ ] Strong `JWT_SECRET`; `SEED_DEMO_DATA=false`
- [ ] ML service reachable from backend; `ML_API_KEY` matches on both
- [ ] Real keys where wanted: Google Maps (app), PayHere (`PAYMENTS_GATEWAY=payhere`),
      FCM (`NOTIFICATIONS_PUSH_PROVIDER=fcm`), email provider
- [ ] HTTPS/custom domain (backend is proxy-aware via `forward-headers-strategy`)
- [ ] At least one `ADMIN` user seeded (admins are not self-registerable)
- [ ] `SENTRY_DSN` set for error monitoring (optional)
