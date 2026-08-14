-- Bookings / jobs (P4.2). A booking snapshots the pricing breakdown at creation
-- time so the customer is charged exactly the quote they saw. The job lifecycle
-- (accept / en-route / started / completed …) is driven by the status column (P4.3).

CREATE TABLE bookings (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id        UUID NOT NULL REFERENCES users (id),
    provider_id        UUID NOT NULL REFERENCES users (id),
    skill_id           UUID NOT NULL REFERENCES skills (id),
    status             VARCHAR(20)  NOT NULL DEFAULT 'REQUESTED',

    scheduled_at       TIMESTAMPTZ  NOT NULL,
    estimated_hours    NUMERIC(5, 2) NOT NULL,
    address_line       VARCHAR(255),
    latitude           DOUBLE PRECISION,
    longitude          DOUBLE PRECISION,
    task_title         VARCHAR(150),
    description        VARCHAR(1000),
    contact_name       VARCHAR(120),
    contact_phone      VARCHAR(30),
    request_expires_at TIMESTAMPTZ,

    -- pricing snapshot (from the dynamic pricing engine, P4.1)
    base_price         NUMERIC(10, 2) NOT NULL,
    hourly_rate        NUMERIC(10, 2) NOT NULL,
    working_hours      NUMERIC(5, 2)  NOT NULL,
    working_fee        NUMERIC(10, 2) NOT NULL,
    travel_distance_km NUMERIC(8, 2)  NOT NULL DEFAULT 0,
    travel_fee         NUMERIC(10, 2) NOT NULL DEFAULT 0,
    total_price        NUMERIC(10, 2) NOT NULL,

    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_bookings_customer ON bookings (customer_id);
CREATE INDEX idx_bookings_provider ON bookings (provider_id);
CREATE INDEX idx_bookings_status   ON bookings (status);
