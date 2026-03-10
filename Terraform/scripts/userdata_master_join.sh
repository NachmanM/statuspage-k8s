#!/bin/bash
set -euo pipefail

# ----------------------
# Configuration
# ----------------------
AwsRegion="us-east-1"
ClusterName="NachHi"
SsmJoinCpParam="/k8s/${ClusterName}/Join/ControlPlane"
SsmJoinWorkerParam="/k8s/${ClusterName}/Join/Worker"

export AWS_REGION="${AwsRegion}"

exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "==> Starting Master Node user-data script"
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
    echo "==> Waiting for fresh Control Plane join command in SSM (<= 60s old)..."
    
    while true; do
        TimestampStr=$(aws ssm describe-parameters \
            --region "${AwsRegion}" \
            --parameter-filters "Key=Name,Values=${SsmJoinCpParam}" \
            --query "Parameters[0].LastModifiedDate" \
            --output text 2>/dev/null || true)

        if [ "$TimestampStr" != "None" ] && [ -n "$TimestampStr" ]; then
            LastModified=$(date -d "$TimestampStr" +%s)
            CurrentTime=$(date +%s)
            Age=$((CurrentTime - LastModified))

            # Allow for minor clock skew by accepting Age >= -5
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
        --name "${SsmJoinCpParam}" \
        --with-decryption \
        --query "Parameter.Value" \
        --output text \
        --region "${AwsRegion}")
    
    echo "==> Executing Control Plane join command..."
    eval "$JoinCommand"
    mkdir -p /root/.kube
    cp -f /etc/kubernetes/admin.conf /root/.kube/config
    chmod 600 /root/.kube/config
else
    echo "==> Node is already part of the cluster. Skipping join."
fi

# ----------------------
# Configure Token Refresh Cron Job
# ----------------------
echo "==> Deploying SSM token refresh script..."

cat << 'EOF' > /usr/local/bin/update-ssm-join.sh
#!/bin/bash
set -euo pipefail

AwsRegion="us-east-1"
ClusterName="NachHi"
SsmJoinCpParam="/k8s/${ClusterName}/Join/ControlPlane"
SsmJoinWorkerParam="/k8s/${ClusterName}/Join/Worker"

export KUBECONFIG=/etc/kubernetes/admin.conf

echo "Generating and updating SSM with fresh join commands..."
CertKey=$(kubeadm init phase upload-certs --upload-certs 2>/dev/null | tail -n 1)
WorkerJoinCommand=$(kubeadm token create --print-join-command)
ControlPlaneJoinCommand="${WorkerJoinCommand} --control-plane --certificate-key ${CertKey}"

aws ssm put-parameter \
  --name "${SsmJoinWorkerParam}" \
  --type "SecureString" \
  --overwrite \
  --value "${WorkerJoinCommand}" \
  --region "${AwsRegion}"

aws ssm put-parameter \
  --name "${SsmJoinCpParam}" \
  --type "SecureString" \
  --overwrite \
  --value "${ControlPlaneJoinCommand}" \
  --region "${AwsRegion}"

echo "SSM parameters updated successfully."
EOF

chmod +x /usr/local/bin/update-ssm-join.sh

# Install the cron job
if ! crontab -l 2>/dev/null | grep -q "update-ssm-join.sh"; then
    (crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/update-ssm-join.sh > /var/log/update-ssm-join.log 2>&1") | crontab -
    echo "==> Cron job configured."
fi

date
echo "==> Master Node deployment complete."