#!/bin/bash
# The public entry point is NOT the ALB directly (samudrayan-internal-alb has
# Scheme=internal, no public DNS). Real traffic flow is:
#   client -> API Gateway (HTTP API "samudrayan-api", a75odfbupl) -> VPC Link
#          -> internal ALB listener -> ECS
#
# This API Gateway was provisioned out-of-band (no script for it existed
# anywhere in this repo before 2026-08-07) and its route table drifted from
# step4.sh's ALB rules: notifications/dashboard/partners had ALB listener
# rules added but no API Gateway route, so requests 404'd from API Gateway
# before ever reaching the ALB. Re-run this after step4.sh whenever a new
# path prefix is added, to keep both routing layers in sync.
set -euo pipefail

API_ID=a75odfbupl
VPC_LINK_INTEGRATION_URI=arn:aws:elasticloadbalancing:ap-south-1:767828731265:listener/app/samudrayan-internal-alb/ffd3ac86b6fb265c/62ad5e5d911528fd
CONNECTION_ID=ch929b  # samudrayan-vpc-link

# Every prefix here must also have a matching path-pattern rule in step4.sh's
# ALB listener rules — API Gateway just blind-proxies to the ALB, which does
# the actual per-service routing.
PATHS=(auth users master homestays restaurants tourism verification admin \
       marketplace learning csr events blue-economy feedback rewards \
       notifications dashboard partners)

EXISTING_ROUTE_KEYS=$(aws apigatewayv2 get-routes --api-id "$API_ID" --query 'Items[].RouteKey' --output text)

for path in "${PATHS[@]}"; do
  if echo "$EXISTING_ROUTE_KEYS" | grep -qF "ANY /api/v1/${path}/{proxy+}"; then
    echo "=== /api/v1/${path} already routed, skipping ==="
    continue
  fi

  echo "=== ensuring routes for /api/v1/${path} ==="

  BARE_INTEGRATION=$(aws apigatewayv2 create-integration \
    --api-id "$API_ID" \
    --integration-type HTTP_PROXY \
    --integration-method ANY \
    --connection-type VPC_LINK \
    --connection-id "$CONNECTION_ID" \
    --integration-uri "$VPC_LINK_INTEGRATION_URI" \
    --payload-format-version 1.0 \
    --query 'IntegrationId' --output text)

  PROXY_INTEGRATION=$(aws apigatewayv2 create-integration \
    --api-id "$API_ID" \
    --integration-type HTTP_PROXY \
    --integration-method ANY \
    --connection-type VPC_LINK \
    --connection-id "$CONNECTION_ID" \
    --integration-uri "$VPC_LINK_INTEGRATION_URI" \
    --payload-format-version 1.0 \
    --query 'IntegrationId' --output text)

  aws apigatewayv2 create-route --api-id "$API_ID" \
    --route-key "ANY /api/v1/${path}" \
    --target "integrations/${BARE_INTEGRATION}"

  aws apigatewayv2 create-route --api-id "$API_ID" \
    --route-key "ANY /api/v1/${path}/{proxy+}" \
    --target "integrations/${PROXY_INTEGRATION}"
done

# $default stage has AutoDeploy=true, so no explicit deployment step is needed.
