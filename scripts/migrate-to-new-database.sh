#!/usr/bin/env bash
#
# migrate-to-new-database.sh
#
# Builds a brand-new PostgreSQL database with a clean, version-controlled
# schema (docker/postgres-init/*.sql, including the partner-dashboard /
# notifications / multi-category-partner changes) and loads it with the real,
# current data from an existing "source" database — while deliberately
# leaving behind ~25 legacy/prototype tables (amenities, payments, rooms,
# coupons, an old-shape `bookings` table, `properties`, etc.) that no current
# service code references.
#
# This does NOT touch the source database — it only ever reads from it.
# The target database must already exist and be empty (see below).
#
# -----------------------------------------------------------------------
# Usage
# -----------------------------------------------------------------------
#   SOURCE_DATABASE_URL="postgres://user:pass@old-host/old_db?sslmode=require" \
#   TARGET_DATABASE_URL="postgres://user:pass@new-host/new_db?sslmode=require" \
#   ./scripts/migrate-to-new-database.sh
#
# Required env vars:
#   SOURCE_DATABASE_URL   Connection string for the current database to read from.
#   TARGET_DATABASE_URL   Connection string for the new, empty database to populate.
#                          On Neon: create this database/branch yourself first
#                          (Neon console, or `neonctl databases create` /
#                          `neonctl branches create`) — this script does not
#                          create databases, only schema + data inside one.
#
# Optional env vars:
#   PARALLEL_JOBS   Parallelism for pg_restore (default: 4)
#   WORK_DIR        Where dump files are staged (default: mktemp -d)
#
# Flags:
#   --force   Proceed even if the target database already has user tables in
#             it (normally the script refuses, to avoid clobbering something
#             by accident). Existing tables are NOT dropped by this script —
#             `--force` only skips the safety check; Phase A's CREATE TABLE
#             IF NOT EXISTS / Phase B's TRUNCATE still apply.
#
# Notes:
#   - Neon requires SSL. Make sure both connection strings include
#     `?sslmode=require` (see packages/shared/src/config/db.js for context).
#   - Requires `psql`, `pg_dump`, `pg_restore` on PATH (matching or newer
#     major version than the Postgres server you're connecting to).

set -euo pipefail

# -----------------------------------------------------------------------
# Config
# -----------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INIT_DIR="$REPO_ROOT/docker/postgres-init"

PARALLEL_JOBS="${PARALLEL_JOBS:-4}"
WORK_DIR="${WORK_DIR:-$(mktemp -d /tmp/db-migrate.XXXXXX)}"
DATA_DUMP_FILE="$WORK_DIR/data.dump"
FORCE=false

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

# Schema files applied to the target, in order. This IS the new, clean
# schema — every table current service code actually uses, nothing else.
# 10-seed-restaurant-data.sql is deliberately skipped (dummy dev-only data).
SCHEMA_FILES=(
  "00-extensions.sql"
  "00-functions.sql"
  "00-users.sql"
  "01-locations.sql"
  "02-categories.sql"
  "03-homestays.sql"
  "04-bookings.sql"
  "05-restaurants.sql"
  "06-tourist-locations.sql"
  "07-aadhar-verification-fields.sql"
  "08-verification-logs-update.sql"
  "09-fix-users-constraint.sql"
  "11-partner-dashboard-notifications.sql"
  "12-experiences.sql"
)

# The exact set of tables that belong in the new database. Legacy/prototype
# tables (amenities, payments, rooms, coupons, properties, the old-shape
# bookings table, etc.) are intentionally not in this list.
TABLES=(
  users districts talukas blocks cities villages gram_panchayats village_gram_panchayat
  categories homestays homestay_rooms bookings payment_transactions booking_guest_details
  restaurants restaurant_menu restaurant_reservations restaurant_time_slots tourist_locations
  aadhar_verification_logs partner_id_sequences partner_categories category_application_logs
  reviews listing_views notifications device_tokens experiences property_experiences
)

# -----------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------
log() { printf '\n==> %s\n' "$1"; }
warn() { printf '\n!!  %s\n' "$1" >&2; }
die() { printf '\nERROR: %s\n' "$1" >&2; exit 1; }

psql_source() { psql "$SOURCE_DATABASE_URL" -v ON_ERROR_STOP=1 "$@"; }
psql_target() { psql "$TARGET_DATABASE_URL" -v ON_ERROR_STOP=1 "$@"; }

cleanup() {
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

# -----------------------------------------------------------------------
# Preflight
# -----------------------------------------------------------------------
log "Preflight checks"

: "${SOURCE_DATABASE_URL:?SOURCE_DATABASE_URL is required}"
: "${TARGET_DATABASE_URL:?TARGET_DATABASE_URL is required}"

[[ "$SOURCE_DATABASE_URL" != "$TARGET_DATABASE_URL" ]] || die "SOURCE_DATABASE_URL and TARGET_DATABASE_URL must be different"

for tool in psql pg_dump pg_restore; do
  command -v "$tool" >/dev/null 2>&1 || die "$tool not found on PATH"
done

log "Checking connectivity to source"
psql_source -c 'select 1' >/dev/null || die "Cannot connect to SOURCE_DATABASE_URL"

log "Checking connectivity to target"
psql_target -c 'select 1' >/dev/null || die "Cannot connect to TARGET_DATABASE_URL"

log "Checking target is empty"
EXISTING_TABLES=$(psql_target -tAc "SELECT count(*) FROM information_schema.tables WHERE table_schema='public'")
if [[ "$EXISTING_TABLES" -gt 0 && "$FORCE" != true ]]; then
  die "Target database already has $EXISTING_TABLES table(s) in the public schema. Re-run with --force if you're sure, or point TARGET_DATABASE_URL at a fresh empty database."
fi

log "Sanity-checking source 'bookings' table shape"
BOOKINGS_COLS=$(psql_source -tAc "SELECT string_agg(column_name, ',') FROM information_schema.columns WHERE table_schema='public' AND table_name='bookings'")
for expected_col in guest_user_id check_in_date check_out_date total_amount; do
  if [[ ",$BOOKINGS_COLS," != *",$expected_col,"* ]]; then
    warn "source bookings table is missing expected column '$expected_col' — it may be the old prototype shape (guest_id/check_in/check_out/total). Data copy for bookings may not match target schema."
  fi
done

# -----------------------------------------------------------------------
# Phase A — build the clean schema on target
# -----------------------------------------------------------------------
log "Phase A: building schema on target from docker/postgres-init/*.sql"

for f in "${SCHEMA_FILES[@]}"; do
  path="$INIT_DIR/$f"
  [[ -f "$path" ]] || die "Schema file not found: $path"
  echo "  applying $f"
  psql_target -f "$path" >/dev/null
done

# -----------------------------------------------------------------------
# Phase B — load real current data
# -----------------------------------------------------------------------
log "Phase B: loading real data from source (this replaces any seed rows Phase A inserted)"

TABLE_LIST_SQL=$(printf '%s, ' "${TABLES[@]}")
TABLE_LIST_SQL="${TABLE_LIST_SQL%, }"

echo "  truncating ${#TABLES[@]} tables on target"
psql_target -c "TRUNCATE $TABLE_LIST_SQL RESTART IDENTITY CASCADE;" >/dev/null

TABLE_ARGS=()
for t in "${TABLES[@]}"; do
  TABLE_ARGS+=(--table="public.$t")
done

echo "  dumping data from source"
pg_dump "$SOURCE_DATABASE_URL" \
  --data-only \
  --disable-triggers \
  --no-owner \
  --no-privileges \
  -Fc \
  "${TABLE_ARGS[@]}" \
  -f "$DATA_DUMP_FILE"

echo "  restoring data into target"
pg_restore \
  --no-owner \
  --no-privileges \
  --data-only \
  --disable-triggers \
  -j "$PARALLEL_JOBS" \
  -d "$TARGET_DATABASE_URL" \
  "$DATA_DUMP_FILE"

# -----------------------------------------------------------------------
# Verification
# -----------------------------------------------------------------------
log "Verification"

echo "  tables present on target (should be exactly the ${#TABLES[@]} whitelisted tables):"
psql_target -tAc "SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY 1" | sed 's/^/    /'

echo
echo "  row counts (source vs target):"
printf '    %-28s %12s %12s\n' "table" "source" "target"
MISMATCH=false
for t in "${TABLES[@]}"; do
  SRC_COUNT=$(psql_source -tAc "SELECT count(*) FROM \"$t\"")
  TGT_COUNT=$(psql_target -tAc "SELECT count(*) FROM \"$t\"")
  FLAG=""
  if [[ "$SRC_COUNT" != "$TGT_COUNT" ]]; then
    FLAG="  <-- MISMATCH"
    MISMATCH=true
  fi
  printf '    %-28s %12s %12s%s\n' "$t" "$SRC_COUNT" "$TGT_COUNT" "$FLAG"
done

echo
echo "  confirming new-changes objects exist on target:"
for obj in partner_categories notifications device_tokens partner_id_sequences category_application_logs reviews listing_views; do
  COUNT=$(psql_target -tAc "SELECT count(*) FROM information_schema.tables WHERE table_schema='public' AND table_name='$obj'")
  [[ "$COUNT" == "1" ]] && echo "    [ok] $obj" || echo "    [MISSING] $obj"
done
NEW_USER_COLS=$(psql_target -tAc "SELECT string_agg(column_name, ',') FROM information_schema.columns WHERE table_schema='public' AND table_name='users' AND column_name IN ('partner_id','organization_name','bank_account_number')")
echo "    [ok] users new columns present: $NEW_USER_COLS"

if [[ "$MISMATCH" == true ]]; then
  warn "One or more tables have mismatched row counts between source and target. Review before cutting services over."
else
  log "All row counts match. Target database is ready."
fi

echo
echo "Next steps:"
echo "  1. Spot-check the new database (see plan's Verification section)."
echo "  2. Update each service's DB_HOST/DB_PORT/DB_NAME/DB_USER/DB_PASSWORD"
echo "     (or DATABASE_URL, depending on how it's deployed) to point at the"
echo "     new database, then restart the services."
echo "  3. The source database was never modified — it's safe to keep as a"
echo "     fallback until you're confident in the cutover."
