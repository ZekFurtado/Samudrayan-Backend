# Local dev DB init scripts

This is a curated, numbered copy of the schema-creation scripts from `../../scripts/`,
used only to seed the local `postgres` container in `docker-compose.yml` via
`docker-entrypoint-initdb.d` (which runs `*.sql`/`*.sh` files in alphabetical order on
first container start).

The original `scripts/` directory is left untouched — this folder only contains copies.

Intentionally **excluded** from this sequence (kept in `scripts/` for manual/reference use only):
- `rollback-tourist-images-update.sql` — a rollback script, not part of forward setup.
- `update-tourist-locations-images-*.sql` (`-BROKEN`, `-fixed`, `-complete-fixed`, `-final`,
  `-efficient`, `-step-by-step`) and `01-structure-changes.sql`/`02-update-data.sql`/
  `03-finalize-changes.sql` — a patch series that backfills `tourist_locations` with real
  Firebase Storage image URLs from the production bucket. Not needed to validate the service
  split locally, and several of the variants are broken/superseded duplicates of each other.
- `insert-zek-user.sql` / `update-zek-to-admin.sql` — one-off scripts that provision a specific
  developer's personal account, not general seed data.
- `create-users.js`, `setup-database.js`, `setup-locations.js`, `generate-update-statements.py` —
  Node/Python scripts, not picked up by `docker-entrypoint-initdb.d` anyway (only `.sql`/`.sh`
  run automatically).

If you need production-like seed data for `tourist_locations` locally, run the relevant
`update-tourist-locations-images-*.sql` script from `scripts/` manually against the local
container after it's up.
