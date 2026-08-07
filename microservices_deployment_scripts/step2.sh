#!/bin/bash
set -euo pipefail

VPC_ID=vpc-0ba70da9843e30a23   # fill in your actual VPC ID

for entry in auth:4001 users:4002 master:4003 booking:4004 restaurants:4005 \
             tourism:4006 verification:4007 admin:4008 marketplace:4009 \
             learning:4010 csr:4011 events:4012 blue-economy:4013 \
             feedback:4014 rewards:4015; do
  svc="${entry%%:*}"
  port="${entry##*:}"

  echo "=== creating target group: ${svc}-tg (port $port) ==="
  aws elbv2 create-target-group \
    --name "${svc}-tg" \
    --protocol HTTP \
    --port "$port" \
    --vpc-id "$VPC_ID" \
    --target-type ip \
    --health-check-path /health \
    --health-check-protocol HTTP \
    --health-check-interval-seconds 30
done