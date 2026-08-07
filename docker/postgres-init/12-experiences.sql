-- =============================================================================
-- Tourism "Experiences" Module — Database Schema
-- Run order: after 03-homestays.sql
-- Idempotent: safe to re-run against an already-migrated database.
--
-- Backfills schema for services/tourism/src/repositories/TourismRepository.js,
-- which has queried `experiences` and `property_experiences` since before this
-- module existed in tracked SQL — the tables were previously created directly
-- against the hosted database out-of-band. `property_experiences.property_id`
-- is defined here as a FK to `homestays(id)`, matching how the repository
-- actually joins it (`INNER JOIN homestays h ON pe.property_id = h.id`), not
-- the legacy `properties` table it referenced in the original ad-hoc schema.
-- =============================================================================

CREATE TABLE IF NOT EXISTS experiences (
    id              VARCHAR(64)     PRIMARY KEY,
    title           VARCHAR(160)    NOT NULL,
    description     TEXT,
    price           NUMERIC(10, 2)  NOT NULL CHECK (price >= 0)
);

CREATE TABLE IF NOT EXISTS property_experiences (
    property_id     UUID            NOT NULL REFERENCES homestays(id) ON DELETE CASCADE,
    experience_id   VARCHAR(64)     NOT NULL REFERENCES experiences(id) ON DELETE CASCADE,

    PRIMARY KEY (property_id, experience_id)
);

CREATE INDEX IF NOT EXISTS idx_property_experiences_experience_id ON property_experiences(experience_id);

COMMENT ON TABLE experiences IS 'Tourism experience catalog (e.g. "Dolphin Safari", "Mangrove Trek") offered by properties';
COMMENT ON TABLE property_experiences IS 'Join table linking homestays to the experiences they offer';
