-- Per-category push-notification preferences (P8.5). A missing row means the
-- category is enabled (opt-out model). In-app inbox entries are always kept;
-- this only gates push delivery.

CREATE TABLE notification_preferences (
    id            UUID PRIMARY KEY,
    user_id       UUID NOT NULL,
    category      VARCHAR(20) NOT NULL,
    push_enabled  BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ NOT NULL,
    updated_at    TIMESTAMPTZ NOT NULL,
    CONSTRAINT uq_notif_pref UNIQUE (user_id, category)
);

CREATE INDEX idx_notif_pref_user ON notification_preferences (user_id);
