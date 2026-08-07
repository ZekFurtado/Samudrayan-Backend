#!/bin/bash
set -euo pipefail

for svc in auth users master booking restaurants tourism verification admin \
           marketplace learning csr events blue-economy feedback rewards; do
  TG_ARN=$(aws elbv2 describe-target-groups \
    --names "${svc}-tg" \
    --query 'TargetGroups[0].TargetGroupArn' --output text)

  echo "=== $svc ==="
  aws elbv2 describe-target-health \
    --target-group-arn "$TG_ARN" \
    --query 'TargetHealthDescriptions[].{Target:Target.Id,Port:Target.Port,State:TargetHealth.State,Reason:TargetHealth.Reason}' \
    --output table
done
