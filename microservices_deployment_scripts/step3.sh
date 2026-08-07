#!/bin/bash
ALB_ARN=arn:aws:elasticloadbalancing:ap-south-1:767828731265:loadbalancer/app/samudrayan-internal-alb/ffd3ac86b6fb265c
LISTENER_ARN=$(aws elbv2 create-listener \
  --load-balancer-arn $ALB_ARN \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=fixed-response,FixedResponseConfig="{MessageBody=Not Found,StatusCode=404,ContentType=text/plain}" \
  --query 'Listeners[0].ListenerArn' --output text)

echo "LISTENER_ARN=$LISTENER_ARN"
