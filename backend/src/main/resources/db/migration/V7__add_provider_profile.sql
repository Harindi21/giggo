-- Admin-curated service taxonomy
CREATE TABLE categories (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(500),
    active      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE skills (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES categories (id) ON DELETE CASCADE,
    name        VARCHAR(100) NOT NULL,
    active      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (category_id, name)
);

CREATE INDEX idx_skills_category ON skills (category_id);

-- One profile per provider user
CREATE TABLE provider_profiles (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           UUID NOT NULL UNIQUE REFERENCES users (id) ON DELETE CASCADE,
    bio               VARCHAR(1000),
    years_experience  INT NOT NULL DEFAULT 0,
    available          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Which skills a provider offers (many-to-many)
CREATE TABLE provider_skills (
    provider_profile_id UUID NOT NULL REFERENCES provider_profiles (id) ON DELETE CASCADE,
    skill_id            UUID NOT NULL REFERENCES skills (id) ON DELETE CASCADE,
    PRIMARY KEY (provider_profile_id, skill_id)
);