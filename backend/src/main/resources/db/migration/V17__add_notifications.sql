-- In-app notifications + device push tokens (P8.1).

CREATE TABLE notifications (
    id          UUID PRIMARY KEY,
    user_id     UUID NOT NULL,
    type        VARCHAR(40) NOT NULL,
    title       VARCHAR(150) NOT NULL,
    body        VARCHAR(500) NOT NULL,
    booking_id  UUID,
    read_at     TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_notifications_user ON notifications (user_id, created_at DESC);

CREATE TABLE device_tokens (
    id          UUID PRIMARY KEY,
    user_id     UUID NOT NULL,
    token       VARCHAR(300) NOT NULL UNIQUE,
    platform    VARCHAR(10) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL,
    updated_at  TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_device_tokens_user ON device_tokens (user_id);
