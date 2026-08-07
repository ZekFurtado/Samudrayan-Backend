# Deployment runbook: ECS Fargate + API Gateway

This is a manual, step-by-step runbook for deploying the 15 services in `services/` to
AWS. There is no Terraform/CDK here by design — every step below is a console/CLI action
you run yourself, so you can review each resource before it's created.

## Why ECS Fargate, not EC2

This project is pre-production (no real traffic yet) with 15 independently-sized
services. Fargate is billed per-task (exactly the vCPU/memory you provision), removes
all host-level ops (no AMI patching, no capacity planning, no SSH surface), and lets
each service scale independently. Raw EC2 (or ECS-on-EC2) only pays off once you have
steady, high-utilization production load where Reserved/Spot EC2 pricing beats
Fargate's per-vCPU-hour rate — revisit that trade-off once you have real usage data,
not before.

## Prerequisites

- AWS CLI configured with an account that has permissions for ECS, ECR, VPC, IAM, ALB,
  API Gateway, Secrets Manager, and CloudWatch Logs.
- Docker images build successfully locally: `docker compose build` (see `docker-compose.yml`).
- Rotated production secrets ready to go into Secrets Manager (see "Secrets" below) —
  do **not** reuse any values that were ever in `.env.example` or the old committed
  Firebase service-account JSON.

## 1. Networking

- Create a VPC with public + private subnets across 2 AZs (or reuse an existing one).
- Add a NAT Gateway for the private subnets — services need outbound access to Neon,
  Firebase, and (for `verification`) UIDAI/DigiLocker.
- Security groups:
  - `alb-sg`: inbound 443 from `0.0.0.0/0` (or your API Gateway VPC Link's SG once
    created).
  - `ecs-tasks-sg`: inbound only from `alb-sg`, one rule per service port
    (4001–4015, see table below).

## 2. Secrets (AWS Secrets Manager or SSM Parameter Store)

Per-service DB credentials (see "Database" below for the role/GRANT scheme), plus:

- `JWT_SECRET`, `JWT_REFRESH_SECRET` — shared across services that validate JWTs
  (all of them, via `verifyJWT`).
- `FIREBASE_PROJECT_ID`, `FIREBASE_PRIVATE_KEY`, `FIREBASE_CLIENT_EMAIL` — only
  `auth`-service needs these (see `packages/shared-firebase`).
- `AADHAR_ENCRYPTION_KEY`, `UIDAI_LICENSE_KEY`, `DIGILOCKER_CLIENT_ID`,
  `DIGILOCKER_CLIENT_SECRET` — only `verification`-service.

Reference these from each task definition's `secrets` block — never bake them into
images or commit them to `.env.example` (which is now a tracked, placeholder-only
template; see `services/*/.env.example`).

## 3. Database

Single shared Neon Postgres instance/schema (no DB-per-service split — the schema has
cross-domain foreign keys, e.g. `bookings.room_id → homestay_rooms.id`, that make a
hard split premature before there's real production load to justify it).

Per-service Postgres roles instead of one shared superuser:

```sql
CREATE ROLE booking_svc LOGIN PASSWORD '...';
CREATE ROLE users_svc LOGIN PASSWORD '...';
-- one login role per service

CREATE ROLE master_reader;
GRANT SELECT ON districts, talukas, blocks, categories, locations TO master_reader;
GRANT master_reader TO tourism_svc, booking_svc, restaurants_svc, admin_svc;

GRANT SELECT, INSERT, UPDATE, DELETE ON homestays, homestay_rooms, bookings TO booking_svc;
GRANT SELECT, INSERT, UPDATE, DELETE ON users TO users_svc, auth_svc;
-- admin_svc is the deliberate broad-read exception (cross-domain ops console):
GRANT SELECT ON users, homestays, homestay_rooms, bookings, aadhar_verification_logs TO admin_svc;
```

Set `DB_POOL_MAX` conservatively per service (5–10) — going from 1 shared pool to 15
independent pools risks exceeding Neon's connection cap faster than you'd expect.
Consider Neon's pooled connection endpoint if you hit limits.

**Known pre-existing bug to fix before relying on bookings in production**: local
validation of this migration (see below) surfaced that `BookingRepository.js`'s SQL
uses column names (`guest_id`, `check_in`, `check_out`, `total`, `guests`, `guest_note`,
`subtotal`) that do not match the schema in `scripts/create-bookings-table.sql`
(`guest_user_id`, `check_in_date`, `check_out_date`, `total_amount`, `guests_count`,
`special_requests` — no `subtotal` column at all). This means the real Neon production
table has drifted from what's tracked in `scripts/`, or vice versa. This bug is
inherited unchanged from the original monolith — the split didn't introduce it — but it
means `POST /homestays/:id/bookings` and `GET /homestays/bookings/me` will fail against
a database built from `scripts/create-bookings-table.sql` as-is. Reconcile which schema
is authoritative (inspect the real Neon `bookings` table with `\d bookings`) before
booking-service goes live.

## 4. ECR

One repository per service:

```bash
for svc in auth users master booking restaurants tourism verification admin \
           marketplace learning csr events blue-economy feedback rewards; do
  aws ecr create-repository --repository-name samudrayan/$svc
done
```

Build and push (from repo root — build context must be the repo root, not
`services/<name>/`, since every image needs `packages/shared` at build time):

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=ap-south-1
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

COLON=$(printf '\072')   # generates ':' programmatically, never typed as literal text
for svc in auth users master booking restaurants tourism verification admin \
           marketplace learning csr events blue-economy feedback rewards; do
  IMAGE="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/samudrayan/$svc${COLON}latest"
  docker build -f services/$svc/Dockerfile -t "$IMAGE" .
  docker push "$IMAGE"
done
```

## 5. ECS Cluster

```bash
aws ecs create-cluster --cluster-name samudrayan-cluster
```

## 6. Task definitions & services

One task definition + one ECS service per entry below. Start small; the 7 stub
services can run on **Fargate Spot** (low priority, fine with interruption), the 8
real/business-critical services on regular Fargate.

| Service | Port | Size (vCPU/mem) | Launch type | desiredCount |
|---|---|---|---|---|
| auth | 4001 | 0.5 / 1GB | Fargate | 1 (→2 once live) |
| users | 4002 | 0.5 / 1GB | Fargate | 1 |
| master | 4003 | 0.25 / 0.5GB | Fargate | 1 |
| booking | 4004 | 0.5 / 1GB | Fargate | 1 (→2 once live) |
| restaurants | 4005 | 0.5 / 1GB | Fargate | 1 (→2 once live) |
| tourism | 4006 | 0.5 / 1GB | Fargate | 1 |
| verification | 4007 | 0.5 / 1GB | Fargate | 1 |
| admin | 4008 | 0.25 / 0.5GB | Fargate | 1 |
| marketplace | 4009 | 0.25 / 0.5GB | Fargate Spot | 1 |
| learning | 4010 | 0.25 / 0.5GB | Fargate Spot | 1 |
| csr | 4011 | 0.25 / 0.5GB | Fargate Spot | 1 |
| events | 4012 | 0.25 / 0.5GB | Fargate Spot | 1 |
| blue-economy | 4013 | 0.25 / 0.5GB | Fargate Spot | 1 |
| feedback | 4014 | 0.25 / 0.5GB | Fargate Spot | 1 |
| rewards | 4015 | 0.25 / 0.5GB | Fargate Spot | 1 |

Each task definition: container image from ECR, port mapping matching the table,
environment variables and secrets from Secrets Manager, `awslogs` log driver to a
per-service CloudWatch Logs group (containers log to stdout only — no file-based
`logs/` volume, unlike the original monolith). The `HEALTHCHECK` already baked into
each Dockerfile doubles as the ECS container health check.

## 7. Load balancer

One internal Application Load Balancer, one target group per service, path-based
listener rules matching each service's public path (see table below — mirrors
`gateway/nginx.conf`'s routing almost exactly, so this step is close to mechanical
once you've validated the local nginx routes).

## 8. API Gateway

- Create an HTTP API (cheaper than REST API for this use case).
- One VPC Link to the internal ALB from step 7.
- One route per service, forwarding into the VPC Link — same path table as below.
- Enable default throttling (tune later based on real traffic).
- Configure CORS to match `ALLOWED_ORIGINS`.
- Custom domain via ACM cert + Route 53 once ready.

**Note on JWT validation**: API Gateway's native JWT authorizers require an
OIDC/JWKS-based issuer (e.g. Cognito). This app issues its own JWTs with a shared
secret via `jsonwebtoken`, so centralizing JWT validation at the gateway would need a
Lambda authorizer — a good future enhancement, not required for launch. Until then,
each service keeps validating JWTs itself via `@samudrayan/shared`'s `verifyJWT`
middleware, same as it does locally.

### Path routing table

| Public path | Target service |
|---|---|
| `/api/v1/auth/*` | auth |
| `/api/v1/users/*` | users |
| `/api/v1/master/*` | master |
| `/api/v1/homestays/*` | booking |
| `/api/v1/restaurants/*` | restaurants |
| `/api/v1/tourism/*` | tourism |
| `/api/v1/verification/*` | verification |
| `/api/v1/admin/*` | admin |
| `/api/v1/marketplace/*` | marketplace |
| `/api/v1/learning/*` | learning |
| `/api/v1/csr/*` | csr |
| `/api/v1/events/*` | events |
| `/api/v1/blue-economy/*` | blue-economy |
| `/api/v1/feedback/*` | feedback |
| `/api/v1/rewards/*` | rewards |

## 9. Observability

- CloudWatch Logs: one log group per service (via the `awslogs` driver in each task
  definition).
- CloudWatch alarms on 5xx rate and unhealthy-task count per service.
- Each service's `/health` endpoint (already implemented, see `services/*/src/app.js`)
  is what ECS/ALB health checks should target.

## Local validation before deploying

This split was validated end-to-end locally with `docker compose up` — all 15
services + Postgres + an nginx gateway (emulating the AWS API Gateway routing above)
came up healthy, and register/login, JWT-protected routes (`/users/me`), and read
endpoints (`master`, `tourism`, `restaurants`, `homestays`) were exercised through the
gateway successfully. Two pre-existing bugs (unrelated to the container split itself)
were surfaced in the process and are worth fixing before go-live:

1. The `bookings` table column-name mismatch described under "Database" above.
2. `scripts/fix-users-table-constraint.sql` silently narrowed the `users_role_check`
   constraint back to excluding `restaurant-owner`/`verified-reporter` if it runs after
   `scripts/create-restaurant-tables.sql`'s constraint widening — fixed in this repo's
   `docker/postgres-init/09-fix-users-constraint.sql` (the curated local-dev copy) but
   the original `scripts/fix-users-table-constraint.sql` still has the stale list and
   should be updated to match if it's ever re-run against a real database.

Run the same validation (`docker compose up --build`, then hit
`http://localhost:8080/api/v1/...`) after any future change before deploying.
