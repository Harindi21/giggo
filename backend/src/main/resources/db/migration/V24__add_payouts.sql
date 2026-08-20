-- Provider payouts (P7.6): a provider withdraws earned (RELEASED) escrow funds;
-- an admin marks the bank transfer done. Earnings themselves are a derived
-- read-model over the payments ledger (see EarningsService, ADR-0010); this
-- table records the withdrawals against that balance.

CREATE TABLE payouts (
    id            UUID PRIMARY KEY,
    provider_id   UUID NOT NULL,
    amount        NUMERIC(12, 2) NOT NULL,
    currency      VARCHAR(3) NOT NULL DEFAULT 'LKR',
    status        VARCHAR(20) NOT NULL,
    method        VARCHAR(30) NOT NULL DEFAULT 'BANK_TRANSFER',
    reference     VARCHAR(160),
    note          VARCHAR(500),
    requested_at  TIMESTAMPTZ NOT NULL,
    processed_at  TIMESTAMPTZ,
    created_at    TIMESTAMPTZ NOT NULL,
    updated_at    TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_payouts_provider ON payouts (provider_id, created_at DESC);
CREATE INDEX idx_payouts_status ON payouts (status);
