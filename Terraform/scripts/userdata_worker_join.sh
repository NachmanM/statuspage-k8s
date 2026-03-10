#!/bin/bash
set -euo pipefail

# ----------------------
# Configuration
# ----------------------
AwsRegion="us-east-1"
ClusterName="NachHi"
SsmJoinWorkerParam="/k8s/${ClusterName}/Join/Worker"

export AWS_REGION="${AwsRegion}"

exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "==> Starting Worker Node user-data script"
date

# ----------------------
# Join Cluster (Idempotent & Timestamp-Aware)
# ----------------------

echo "==> Verifying local DNS and API server reachability..."
NlbEndpoint="master-nlb.nach-hi.click:6443"
while true; do
    if curl -kfsS --max-time 5 "https://${NlbEndpoint}/livez" >/dev/null 2>&1; then
        echo "API server is reachable."
        break
    fi
    echo "Waiting for local DNS/networking to initialize..."
    sleep 5
done

if [ ! -f "/etc/kubernetes/kubelet.conf" ]; then
    echo "==> Waiting for fresh Worker join command in SSM (<= 60s old)..."
    
    while true; do
        TimestampStr=$(aws ssm describe-parameters \
            --region "${AwsRegion}" \
            --parameter-filters "Key=Name,Values=${SsmJoinWorkerParam}" \
            --query "Parameters[0].LastModifiedDate" \
            --output text 2>/dev/null || true)

        if [ "$TimestampStr" != "None" ] && [ -n "$TimestampStr" ]; then
            LastModified=$(date -d "$TimestampStr" +%s)
            CurrentTime=$(date +%s)
            Age=$((CurrentTime - LastModified))

            if [ "$Age" -le 1200 ] && [ "$Age" -ge -5 ]; then
                echo "Parameter is $Age seconds old. Fetching fresh value..."
                break
            fi
            echo "Parameter is $Age seconds old. Waiting for a fresh token..."
        else
            echo "Parameter not found yet. Waiting..."
        fi
        sleep 10
    done

    JoinCommand=$(aws ssm get-parameter \
        --name "${SsmJoinWorkerParam}" \
        --with-decryption \
        --query "Parameter.Value" \
        --output text \
        --region "${AwsRegion}")

    echo "==> Executing Worker join command..."
    eval "$JoinCommand"
else
    echo "==> Node is already part of the cluster. Skipping join."
fi

date
echo "==> Worker Node deployment complete."