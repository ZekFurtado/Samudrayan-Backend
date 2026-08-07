#!/bin/bash
set -euo pipefail

ACCOUNT_ID=767828731265
REGION=ap-south-1
EXEC_ROLE_ARN=arn:aws:iam::767828731265:role/ecsTaskExecutionRole
MS_SECRET_ARN=arn:aws:secretsmanager:ap-south-1:767828731265:secret:Samudrayan-Microservices-rcVBKt

SERVICES=(auth users master booking restaurants tourism verification admin \
          marketplace learning csr events blue-economy feedback rewards)
FAMILIES=(Samudrayan-Auth Samudrayan-Users Samudrayan-Master Samudrayan-Booking Samudrayan-Restaurants \
          Samudrayan-Tourism Samudrayan-Verification Samudrayan-Admin Samudrayan-Marketplace \
          Samudrayan-Learning Samudrayan-CSR Samudrayan-Events Samudrayan-Blue-Economy \
          Samudrayan-Feedback Samudrayan-Rewards)
PORTS=(4001 4002 4003 4004 4005 4006 4007 4008 4009 4010 4011 4012 4013 4014 4015)
CPUS=(512 512 256 512 512 512 512 256 256 256 256 256 256 256 256)
MEMS=(1024 1024 512 1024 1024 1024 1024 512 512 512 512 512 512 512 512)

count=${#SERVICES[@]}
i=0
while [ $i -lt $count ]; do
  svc="${SERVICES[$i]}"
  family="${FAMILIES[$i]}"
  port="${PORTS[$i]}"
  cpu="${CPUS[$i]}"
  mem="${MEMS[$i]}"

  secrets_json="    {\"name\":\"JWT_SECRET\",\"valueFrom\":\"${MS_SECRET_ARN}:JWT_SECRET::\"},
    {\"name\":\"JWT_REFRESH_SECRET\",\"valueFrom\":\"${MS_SECRET_ARN}:JWT_REFRESH_SECRET::\"},
    {\"name\":\"DB_HOST\",\"valueFrom\":\"${MS_SECRET_ARN}:DB_HOST::\"},
    {\"name\":\"DB_PORT\",\"valueFrom\":\"${MS_SECRET_ARN}:DB_PORT::\"},
    {\"name\":\"DB_NAME\",\"valueFrom\":\"${MS_SECRET_ARN}:DB_NAME::\"},
    {\"name\":\"DB_USER\",\"valueFrom\":\"${MS_SECRET_ARN}:DB_USER::\"},
    {\"name\":\"DB_PASSWORD\",\"valueFrom\":\"${MS_SECRET_ARN}:DB_PASSWORD::\"}"

  if [ "$svc" = "auth" ]; then
    secrets_json="${secrets_json},
    {\"name\":\"FIREBASE_PROJECT_ID\",\"valueFrom\":\"${MS_SECRET_ARN}:FIREBASE_PROJECT_ID::\"},
    {\"name\":\"FIREBASE_PRIVATE_KEY\",\"valueFrom\":\"${MS_SECRET_ARN}:FIREBASE_PRIVATE_KEY::\"},
    {\"name\":\"FIREBASE_CLIENT_EMAIL\",\"valueFrom\":\"${MS_SECRET_ARN}:FIREBASE_CLIENT_EMAIL::\"}"
  fi

  cat > "/tmp/taskdef-${svc}.json" <<JSON
{
  "family": "${family}",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "${cpu}",
  "memory": "${mem}",
  "executionRoleArn": "${EXEC_ROLE_ARN}",
  "containerDefinitions": [{
    "name": "${svc}",
    "image": "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/samudrayan/${svc}:latest",
    "portMappings": [{"containerPort": ${port}, "protocol": "tcp"}],
    "environment": [
      {"name": "NODE_ENV", "value": "production"},
      {"name": "PORT", "value": "${port}"},
      {"name": "SERVICE_NAME", "value": "${svc}-service"},
      {"name": "DB_SSL", "value": "true"}
    ],
    "secrets": [
${secrets_json}
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${family}",
        "awslogs-region": "${REGION}",
        "awslogs-stream-prefix": "${svc}"
      }
    }
  }]
}
JSON

  echo "=== registering: ${family} ==="
  aws ecs register-task-definition --cli-input-json "file:///tmp/taskdef-${svc}.json" \
    --query 'taskDefinition.{Family:family,Revision:revision,Status:status}' --output table

  i=$((i + 1))
done
