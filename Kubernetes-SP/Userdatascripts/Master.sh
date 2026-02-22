#!/bin/bash
set -euo pipefail

AwsRegion="us-east-1"
SsmJoinCpParam="/k8s/NachHi/Join/ControlPlane"
export AWS_REGION="${AwsRegion}"


exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "==> Starting join-master user-data script"
date


echo "==> Fetching Control Plane Join Command from SSM"
JoinCmd=$(aws ssm get-parameter --name "${SsmJoinCpParam}" --with-decryption --region "${AwsRegion}" --query "Parameter.Value" --output text)

echo "==> Executing Join Command"
eval $JoinCmd

echo "==> Configuring kubectl"
mkdir -p /root/.kube
cp -f /etc/kubernetes/admin.conf /root/.kube/config
chmod 600 /root/.kube/config

echo "==> Master successfully joined"
date
