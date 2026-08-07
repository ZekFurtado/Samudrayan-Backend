#!/bin/bash
LISTENER_ARN=arn:aws:elasticloadbalancing:ap-south-1:767828731265:listener/app/samudrayan-internal-alb/ffd3ac86b6fb265c/62ad5e5d911528fd
SERVICES=(auth users master booking restaurants tourism verification admin \
          marketplace learning csr events blue-economy feedback rewards \
          users users users)
PATHS=("/api/v1/auth/*" "/api/v1/users/*" "/api/v1/master/*" "/api/v1/homestays/*" \
       "/api/v1/restaurants/*" "/api/v1/tourism/*" "/api/v1/verification/*" "/api/v1/admin/*" \
       "/api/v1/marketplace/*" "/api/v1/learning/*" "/api/v1/csr/*" "/api/v1/events/*" \
       "/api/v1/blue-economy/*" "/api/v1/feedback/*" "/api/v1/rewards/*" \
       "/api/v1/notifications/*" "/api/v1/dashboard/*" "/api/v1/partners/*")
# The last 3 entries route to the users service too (routes/notifications.js,
# routes/partners.js, routes/dashboard.js are all mounted there — see
# services/users/src/app.js) but were missing from this script's original
# provisioning run, which meant those three paths 404'd on the ALB with no
# matching rule (see git history around 2026-08-07).

priority=1
count=${#SERVICES[@]}
i=0
while [ $i -lt $count ]; do
  svc="${SERVICES[$i]}"
  path="${PATHS[$i]}"

  TG_ARN=$(aws elbv2 describe-target-groups \
    --names "${svc}-tg" \
    --query 'TargetGroups[0].TargetGroupArn' --output text)

  echo "=== rule $priority: $path -> $svc ($TG_ARN) ==="
  aws elbv2 create-rule \
    --listener-arn "$LISTENER_ARN" \
    --priority "$priority" \
    --conditions Field=path-pattern,Values="$path" \
    --actions Type=forward,TargetGroupArn="$TG_ARN"

  priority=$((priority + 1))
  i=$((i + 1))
done
