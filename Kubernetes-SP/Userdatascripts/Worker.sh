#!/bin/bash
set -euo pipefail

AwsRegion="us-east-1"
SsmJoinWorkerParam="/k8s/NachHi/Join/Worker"
export AWS_REGION="${AwsRegion}"


exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "==> Starting join-worker user-data script"
date

echo "==> Fetching Worker Join Command from SSM"
JoinCmd=$(aws ssm get-parameter --name "${SsmJoinWorkerParam}" --with-decryption --region "${AwsRegion}" --query "Parameter.Value" --output text)

echo "==> Executing Join Command"
eval $JoinCmd

echo "==> Worker successfully joined"
date