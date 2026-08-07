# Local Deployment Guide

How to run and test the full containerized microservices stack on your own machine. This is the local counterpart to `DEPLOYMENT.md` (which covers the real AWS ECS Fargate deployment) — nothing here touches production.

## Architecture recap

- 15 independent Express services under `services/<name>/`, each with its own `Dockerfile`, `.env`, and port (4001–4015).
- One shared Postgres instance (`postgres:16`), schema bootstrapped from the numbered SQL files in `docker/postgres-init/` on first container start only.
- An nginx container (`gateway`) that emulates the future AWS API Gateway — it path-routes `http://localhost:8080/api/v1/<segment>/...` to the right service container. This is the only port you should hit when testing "the API" as a whole; hitting a service's own port (e.g. `4002`) bypasses the gateway and skips the `/api/v1/<segment>` prefix.
- `packages/shared` and `packages/shared-firebase` are npm workspace packages every service depends on — this is a monorepo (`npm ci --workspace=services/<name> --include-workspace-root` in each Dockerfile), not independent repos.

| Service | Port | Gateway segment |
|---|---|---|
| auth | 4001 | `/api/v1/auth` |
| users | 4002 | `/api/v1/users`, `/api/v1/dashboard`, `/api/v1/notifications`, `/api/v1/partners` |
| master | 4003 | `/api/v1/master` |
| booking (homestays + bookings) | 4004 | `/api/v1/homestays`, `/api/v1/bookings` |
| restaurants | 4005 | `/api/v1/restaurants` |
| tourism | 4006 | `/api/v1/tourism` |
| verification | 4007 | `/api/v1/verification` |
| admin | 4008 | `/api/v1/admin` |
| marketplace | 4009 | `/api/v1/marketplace` |
| learning | 4010 | `/api/v1/learning` |
| csr | 4011 | `/api/v1/csr` |
| events | 4012 | `/api/v1/events` |
| blue-economy | 4013 | `/api/v1/blue-economy` |
| feedback | 4014 | `/api/v1/feedback` |
| rewards | 4015 | `/api/v1/rewards` |
| postgres | 5432 | — (not routed through gateway) |
| gateway | 8080 | entry point for everything above |

## Prerequisites

- **Docker Desktop** running. Check with `docker info` — if it errors with a socket-connect failure, Docker Desktop isn't running yet; launch it (`open -a Docker` on macOS) and wait ~20–30s before retrying.
- **Node.js 20+** and npm, only needed if you want to run a service directly on the host instead of in a container (see the alternative workflow near the bottom), or to run one-off scripts against the DB.
- Each `services/<name>/.env` file must exist locally (they're gitignored — real secrets never get committed). If one's missing, copy its `.env.example` sibling: `cp services/<name>/.env.example services/<name>/.env`. The values already in each `.env.example` are fine defaults for local dev (dummy JWT secrets, etc.) — you don't need real Firebase credentials to boot everything, only to exercise `/auth/login` and `/auth/register` (see the Firebase caveat below).

## Starting everything

From the repo root:

```bash
docker compose up -d --build
```

First run will take a few minutes (building 15 images + pulling `postgres:16`/`nginx:1.27-alpine`). Postgres runs its `docker/postgres-init/*.sql` files **only on first container start against a fresh volume** — if you've run this before and have an existing `pgdata` volume, those scripts are skipped (see "Applying a new schema migration" below).

Check everything is up and healthy:

```bash
docker compose ps
```

Every app service has a `/health` check baked into its Dockerfile; `docker compose ps` will show `(healthy)` once each one responds. `postgres` shows healthy once `pg_isready` succeeds. `gateway` has no healthcheck defined — if it's `Running` and the services it depends on are healthy, it's good.

To bring up only a subset (faster iteration while working on one area):

```bash
docker compose up -d --build postgres users booking gateway
```

## Smoke-testing through the gateway

```bash
curl http://localhost:8080/api/v1/health
curl http://localhost:8080/api/v1/homestays          # public listing endpoint, no auth needed
```

If these hang or connection-refuse, `gateway` isn't up — check `docker compose logs gateway`.

## The Firebase / auth caveat

`POST /api/v1/auth/login` and `POST /api/v1/auth/register` call `firebase-admin`'s `getAdmin().auth().getUser(uid)` to verify the Firebase UID is real. Locally, unless you've put real Firebase service-account credentials into `services/auth/.env` (`FIREBASE_PROJECT_ID`/`FIREBASE_PRIVATE_KEY`/`FIREBASE_CLIENT_EMAIL`), this call fails and login/register won't work end-to-end.

Two ways around this for local testing:

**Option A — real Firebase project** (needed if you're testing the Firebase integration itself): drop real service-account credentials into `services/auth/.env` (gitignored, safe to edit locally) and restart the `auth` container. `services/auth/src/services/authService.js` also has a `test-*` UID bypass for `NODE_ENV=development` registration (skips the Firebase existence check, but still requires the row to be inserted via `/register`).

**Option B — mint a JWT directly** (fastest, what was used to verify this backend's endpoints during development): every service trusts the same `JWT_SECRET` (see each `.env`, default `local-dev-jwt-secret-do-not-use-in-prod`), so you can sign a token yourself that matches the payload shape `generateTokens()` produces, as long as the corresponding row already exists in `users`:

```bash
node -e "
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');
const pool = new Pool({ host: 'localhost', port: 5432, database: 'samudrayan_local', user: 'samudrayan', password: 'localdevpassword', ssl: false });
(async () => {
  const { rows } = await pool.query('SELECT * FROM users WHERE firebase_uid = \$1', ['<some-firebase-uid>']);
  const user = rows[0];
  const payload = {
    uid: user.firebase_uid, userId: user.id, email: user.email,
    userType: user.role, district: user.district, taluka: user.taluka, isVerified: user.is_verified
  };
  console.log(jwt.sign(payload, 'local-dev-jwt-secret-do-not-use-in-prod', { expiresIn: '24h', issuer: 'samudrayan-backend', audience: 'samudrayan-app' }));
  await pool.end();
})();
"
```

If there's no user row yet, insert one directly (bypassing Firebase entirely — fine for local-only test data):

```bash
docker compose exec -T postgres psql -U samudrayan -d samudrayan_local -c "
INSERT INTO users (firebase_uid, full_name, email, phone, role, district, taluka, is_verified, status)
VALUES ('test-owner-1', 'Test Owner', 'test-owner-1@example.com', '9123456780', 'homestay-owner', 'Sindhudurg', 'Malvan', true, 'active');
"
```

Use the minted token as `Authorization: Bearer <token>` on any request through the gateway.

## Inspecting/querying the database directly

```bash
docker compose exec -T postgres psql -U samudrayan -d samudrayan_local
```

Or non-interactively:

```bash
docker compose exec -T postgres psql -U samudrayan -d samudrayan_local -c "SELECT id, firebase_uid, role FROM users LIMIT 10;"
```

## Rebuilding after code changes

Docker build contexts are the whole repo root (so `packages/shared*` can be copied in), but each service's Dockerfile only `COPY`s its own `package.json` plus the shared packages' `package.json`s before `npm ci` — editing a service's source under `src/` still requires a rebuild (no bind-mount/hot-reload in the compose file):

```bash
docker compose up -d --build <service-name>
```

Only the one image rebuilds; unaffected containers keep running. If you changed a **shared package** (`packages/shared` or `packages/shared-firebase`), rebuild every service that depends on it (check its Dockerfile for `COPY packages/shared...` lines — currently `auth`, `users`, `booking`, `restaurants`, `admin`).

If you add a new dependency to a service's `package.json`, run `npm install` at the repo root first (updates the root `package-lock.json` and workspace symlinks) before rebuilding its image.

## Applying a new SQL migration to an already-running Postgres

`docker/postgres-init/*.sql` only runs automatically against a brand-new volume. If your `postgres` container already has data, apply a new migration file manually:

```bash
docker compose exec -T postgres psql -U samudrayan -d samudrayan_local < docker/postgres-init/<NN>-<name>.sql
```

These files are written to be idempotent (`CREATE TABLE IF NOT EXISTS`, `ADD COLUMN IF NOT EXISTS`, drop-and-recreate for CHECK constraints) — safe to re-run.

## Logs and troubleshooting

```bash
docker compose logs -f <service-name>        # tail a single service
docker compose logs -f                        # tail everything
```

Common issues:
- **"address already in use" on `docker compose up`**: something else (often a service you started directly on the host with `node src/index.js`) is already bound to that port. `lsof -ti:4004` to find it, kill it, retry.
- **"database ... does not exist" in postgres logs on startup**: usually a stray healthcheck probe from another tool using the wrong DB name — harmless as long as `samudrayan_local` itself shows up in `\l` and the app containers report healthy.
- **"The server does not support SSL connections"**: only happens if you run a service directly on the host (`node src/index.js`) using its `.env`'s `DB_HOST=localhost` without also setting `DB_SSL=false` — the containerized path already sets this via `docker-compose.yml`'s `environment:` block per service, so it shouldn't occur through `docker compose up`.
- **A service is `Restarting` in a loop**: `docker compose logs <service>` almost always shows a DB connection failure (postgres not healthy yet — compose's `depends_on: condition: service_healthy` should prevent this, but check) or a missing required env var.

## Alternative: running a service directly on the host (no Docker)

Useful for faster iteration on one service without a rebuild cycle. Postgres still needs to be up via Docker (`docker compose up -d postgres`), since raw `node src/index.js` has no bundled DB.

```bash
cd services/users
DB_SSL=false node src/index.js
```

`DB_SSL=false` is required here because the service's own `.env` has `DB_HOST=localhost` (for this exact use case) but doesn't hardcode `DB_SSL` — the container path gets it from `docker-compose.yml`'s `environment:` block instead, which doesn't apply when you run outside Docker. Note the gateway won't route to a host-run service (it resolves container hostnames like `users:4002` via Docker's embedded DNS) — hit the service's own port directly (e.g. `http://localhost:4002/me`, without the `/api/v1/users` gateway prefix) while testing this way.

## Stopping / cleanup

```bash
docker compose stop              # stop containers, keep them (and the postgres volume) around
docker compose down              # stop + remove containers, keep the postgres volume (data survives)
docker compose down -v           # stop + remove containers AND the postgres volume (full reset — next `up` re-runs docker/postgres-init/*.sql from scratch)
```

Use `down -v` when you want a genuinely clean slate (e.g. after changing something in `docker/postgres-init/` and wanting it to apply via the normal first-boot path rather than manually).
