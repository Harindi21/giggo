-- Tool marketplace orders (P10.3): a customer buys a tool (direct sale, not
-- escrow). Price is snapshotted at order time.

CREATE TABLE tool_orders (
    id                UUID PRIMARY KEY,
    customer_id       UUID NOT NULL,
    tool_id           UUID NOT NULL REFERENCES tools (id),
    tool_name         VARCHAR(200) NOT NULL,
    unit_price        NUMERIC(12, 2) NOT NULL,
    quantity          INT NOT NULL,
    total_price       NUMERIC(12, 2) NOT NULL,
    currency          VARCHAR(3) NOT NULL DEFAULT 'LKR',
    status            VARCHAR(20) NOT NULL,
    gateway           VARCHAR(30) NOT NULL,
    gateway_ref       VARCHAR(120),
    contact_name      VARCHAR(120),
    contact_phone     VARCHAR(30),
    shipping_address  VARCHAR(400),
    paid_at           TIMESTAMPTZ,
    created_at        TIMESTAMPTZ NOT NULL,
    updated_at        TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_tool_orders_customer ON tool_orders (customer_id, created_at DESC);
