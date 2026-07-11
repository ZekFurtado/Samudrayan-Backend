-- Required by 04-bookings.sql's EXCLUDE USING gist(...) constraint on a UUID column.
-- Not present anywhere in scripts/*.sql — on the real Neon database this was
-- evidently enabled manually via psql outside of any tracked migration, since
-- restoring the schema from scripts/ alone fails without it. Documented here so
-- it's no longer implicit/undiscoverable.
CREATE EXTENSION IF NOT EXISTS btree_gist;
