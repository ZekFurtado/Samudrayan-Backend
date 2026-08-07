#!/bin/bash
set -euo pipefail

CLUSTER=samudrayan-cluster
SUBNET_A=subnet-028d54899d584237b
SUBNET_B=subnet-0b8f0ec561889c813
ECS_SG=sg-0e3db73808340f024

SPOT_SERVICES="marketplace learning csr events blue-economy feedback rewards"

family_for() {
  case "$1" in
    auth) echo "Samudrayan-Auth" ;;
    users) echo "Samudrayan-Users" ;;
    master) echo "Samudrayan-Master" ;;
    booking) echo "Samudrayan-Booking" ;;
    restaurants) echo "Samudrayan-Restaurants" ;;
    tourism) echo "Samudrayan-Tourism" ;;
    verification) echo "Samudrayan-Verification" ;;
    admin) echo "Samudrayan-Admin" ;;
    marketplace) echo "Samudrayan-Marketplace" ;;
    learning) echo "Samudrayan-Learning" ;;
    csr) echo "Samudrayan-CSR" ;;
    events) echo "Samudrayan-Events" ;;
    blue-economy) echo "Samudrayan-Blue-Economy" ;;
    feedback) echo "Samudrayan-Feedback" ;;
    rewards) echo "Samudrayan-Rewards" ;;
  esac
}

for entry in auth:4001 users:4002 master:4003 booking:4004 restaurants:4005 \
             tourism:4006 verification:4007 admin:4008 marketplace:4009 \
             learning:4010 csr:4011 events:4012 blue-economy:4013 \
             feedback:4014 rewards:4015; do
  svc="${entry%%:*}"
  port="${entry##*:}"
  family=$(family_for "$svc")

  TG_ARN=$(aws elbv2 describe-target-groups \
    --names "${svc}-tg" \
    --query 'TargetGroups[0].TargetGroupArn' --output text)

  if echo "$SPOT_SERVICES" | grep -qw "$svc"; then
    LAUNCH_ARGS=(--capacity-provider-strategy "capacityProvider=FARGATE_SPOT,weight=1")
  else
    LAUNCH_ARGS=(--launch-type "FARGATE")
  fi

  echo "=== creating service: $svc (task-def: $family, port $port) ==="
  aws ecs create-service \
    --cluster "$CLUSTER" \
    --service-name "$svc" \
    --task-definition "$family" \
    --desired-count 1 \
    "${LAUNCH_ARGS[@]}" \
    --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_A,$SUBNET_B],securityGroups=[$ECS_SG],assignPublicIp=ENABLED}" \
    --load-balancers "targetGroupArn=${TG_ARN},containerName=${svc},containerPort=${port}"
done