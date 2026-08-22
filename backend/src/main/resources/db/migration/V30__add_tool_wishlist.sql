-- Tool wishlist / save-for-later (P10.3). One row per (user, tool).

CREATE TABLE tool_wishlist (
    id          UUID PRIMARY KEY,
    user_id     UUID NOT NULL,
    tool_id     UUID NOT NULL REFERENCES tools (id),
    created_at  TIMESTAMPTZ NOT NULL,
    CONSTRAINT uq_wishlist_user_tool UNIQUE (user_id, tool_id)
);

CREATE INDEX idx_wishlist_user ON tool_wishlist (user_id, created_at DESC);
