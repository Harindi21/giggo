ALTER TABLE users
    ADD COLUMN phone VARCHAR(20);

CREATE UNIQUE INDEX ux_users_phone ON users (phone);