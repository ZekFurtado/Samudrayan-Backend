#!/bin/bash
ALB_ARN=$(aws elbv2 create-load-balancer \
  --name samudrayan-internal-alb \
  --type application \
  --scheme internal \
  --subnets $SUBNET_A $SUBNET_B \
  --security-groups $ALB_SG \
  --query 'LoadBalancers[0].LoadBalancerArn' --output text)
