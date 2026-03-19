# Kubernetes-SP — Status Page on Kubernetes

A production-grade **Status Page** application deployed on a self-managed Kubernetes cluster running on AWS. The project covers the full lifecycle: infrastructure provisioning, configuration management, container orchestration, CI/CD, and GitOps.

---

## Architecture Overview

```
GitHub Actions (CI) ──> AWS ECR ──> ArgoCD (CD) ──> Kubernetes Cluster
                                                        │
                                    ┌───────────────────┼───────────────────┐
                                    │                   │                   │
                                 Django App        PostgreSQL            Redis
                                (3 replicas)      (StatefulSet)       (Cache/Queue)
                                    │
                              nginx-ingress
                                    │
                              AWS ALB / NLB
                                    │
                              Route53 DNS
```

---

## Tech Stack

| Layer              | Technology                                              |
| ------------------ | ------------------------------------------------------- |
| **Application**    | Python 3.10, Django 5.1, Django REST Framework, Gunicorn |
| **Frontend**       | Node.js 18, Yarn, Tailwind CSS                          |
| **Database**       | PostgreSQL 13                                            |
| **Cache / Queue**  | Redis 4.0, django-rq                                    |
| **Containerization** | Docker (multi-stage build), AWS ECR                   |
| **Orchestration**  | Kubernetes (kubeadm), nginx-ingress, ArgoCD              |
| **IaC**            | Terraform (AWS provider) — EC2, ALB, NLB, ASG, Route53  |
| **Config Mgmt**    | Ansible (geerlingguy.kubernetes, geerlingguy.containerd) |
| **CI/CD**          | GitHub Actions → Docker build & test → ECR push          |
| **Cloud**          | AWS (EC2, ALB, NLB, ECR, Route53, SSM, IAM)             |

---

## Project Structure

```
├── Application/          # Django status page app + Dockerfile
├── k8s/                  # Kubernetes manifests
│   ├── statuspage/       #   App deployment, service, ingress, configmap, secrets
│   ├── postgres/         #   PostgreSQL StatefulSet
│   ├── redis/            #   Redis deployment
│   ├── ingress/          #   nginx-ingress controller
│   └── argocd/           #   ArgoCD GitOps config
├── Terraform/            # AWS infrastructure (EC2, LB, ASG, SG, IAM)
│   ├── modules/          #   Reusable Terraform modules
│   └── scripts/          #   Userdata scripts for kubeadm init/join
├── Ansible/              # Node bootstrapping (containerd + kubeadm)
└── .github/workflows/    # CI pipeline
```

---

## How It Works

1. **Terraform** provisions AWS infrastructure — EC2 instances (master + workers via ASG), load balancers, security groups, and DNS records.
2. **Ansible** bootstraps each node with containerd and kubeadm.
3. **kubeadm** initializes the cluster with Flannel CNI networking.
4. **Kubernetes manifests** deploy the app stack: Django (3 replicas), PostgreSQL, Redis, and nginx-ingress.
5. **GitHub Actions** builds and tests the Docker image on every PR, then pushes to ECR.
6. **ArgoCD** watches the repo and syncs deployments to the cluster.

---

## CI Pipeline

The GitHub Actions workflow (on PR to `main`):

1. Spins up PostgreSQL and Redis service containers
2. Builds the Docker image
3. Runs a health check against the container
4. Pushes the image to AWS ECR tagged with the commit SHA

---

## Key Features

- Incident & maintenance management with status tracking
- REST API for external integrations
- Background job processing (Redis + RQ)
- Multi-factor authentication (OTP / YubiKey)
- Email notifications for subscribers
- External status provider integration (UptimeRobot)
