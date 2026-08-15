-- Payments with platform escrow (P7.1).
-- A payment is initiated for a completed booking, captured into escrow (HELD),
-- then released to the provider minus the platform commission (RELEASED).

CREATE TABLE payments (
    id               UUID PRIMARY KEY,
    booking_id       UUID NOT NULL UNIQUE REFERENCES bookings (id),
    customer_id      UUID NOT NULL,
    provider_id      UUID NOT NULL,
    amount           NUMERIC(12, 2) NOT NULL,
    currency         VARCHAR(3) NOT NULL DEFAULT 'LKR',
    commission       NUMERIC(12, 2) NOT NULL DEFAULT 0,
    provider_payout  NUMERIC(12, 2) NOT NULL DEFAULT 0,
    status           VARCHAR(20) NOT NULL,
    gateway          VARCHAR(30) NOT NULL,
    gateway_ref      VARCHAR(120),
    paid_at          TIMESTAMPTZ,
    released_at      TIMESTAMPTZ,
    refunded_at      TIMESTAMPTZ,
    created_at       TIMESTAMPTZ NOT NULL,
    updated_at       TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_payments_provider ON payments (provider_id);
CREATE INDEX idx_payments_customer ON payments (customer_id);
