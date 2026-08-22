-- Push delivery tracking + retry (P8.6). Every notification records whether its
-- push was SENT / FAILED / SKIPPED (preference off or no devices), how many
-- attempts were made, and when it was last tried, so failed pushes can be retried.

ALTER TABLE notifications ADD COLUMN push_status     VARCHAR(20) NOT NULL DEFAULT 'PENDING';
ALTER TABLE notifications ADD COLUMN push_attempts   INTEGER NOT NULL DEFAULT 0;
ALTER TABLE notifications ADD COLUMN last_attempt_at TIMESTAMPTZ;

CREATE INDEX idx_notifications_push_status ON notifications (push_status);
