# Kubernetes-SP Status Page on Kubernetes

> A production-grade **Status Page** application deployed on a self-managed Kubernetes cluster running on AWS. Covers the full DevOps lifecycle: infrastructure provisioning, container orchestration, CI/CD, and GitOps.

[![CI](https://img.shields.io/github/actions/workflow/status/Hi9841/Kubernetes-SP/CiDockerimage.yml?branch=main&label=CI&style=flat-square)](https://github.com/Hi9841/Kubernetes-SP/blob/main/.github/workflows/CiDockerimage.yml)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-kubeadm-326CE5?style=flat-square&logo=kubernetes&logoColor=white)](https://kubernetes.io)
[![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-EF7B4D?style=flat-square&logo=argo&logoColor=white)](https://argo-cd.readthedocs.io)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?style=flat-square&logo=terraform&logoColor=white)](https://terraform.io)
[![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?style=flat-square&logo=amazonaws&logoColor=white)](https://aws.amazon.com)

---

## Table of Contents

- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [How It Works](#how-it-works)
- [CI/CD Pipeline](#cicd-pipeline)
- [Key Features](#key-features)
- [Getting Started](#getting-started)

---

## Architecture

<img width="1292" height="733" alt="image" src="https://github.com/user-attachments/assets/654099a1-0904-4fc6-8fa9-ba4cf76b67cd" />



**Traffic flow:** Requests enter via Route53 DNS -> AWS load balancer (ALB/NLB) -> nginx-ingress controller -> Django app (3 replicas). The app is backed by a PostgreSQL StatefulSet for persistence and Redis for caching and background job queuing via django-rq. ArgoCD continuously syncs the cluster state from this repository.

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Application** | ![Python](https://img.shields.io/badge/Python-3.10-3776AB?style=flat-square&logo=python&logoColor=white) ![Django](https://img.shields.io/badge/Django-5.1-092E20?style=flat-square&logo=django&logoColor=white) ![Gunicorn](https://img.shields.io/badge/Gunicorn-499848?style=flat-square&logo=gunicorn&logoColor=white) |
| **Frontend** | ![Node.js](https://img.shields.io/badge/Node.js-18-339933?style=flat-square&logo=nodedotjs&logoColor=white) ![Yarn](https://img.shields.io/badge/Yarn-2C8EBB?style=flat-square&logo=yarn&logoColor=white) ![Tailwind](https://img.shields.io/badge/Tailwind_CSS-06B6D4?style=flat-square&logo=tailwindcss&logoColor=white) |
| **Database** | ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13-4169E1?style=flat-square&logo=postgresql&logoColor=white) |
| **Cache / Queue** | ![Redis](https://img.shields.io/badge/Redis-4.0-FF4438?style=flat-square&logo=redis&logoColor=white) |
| **Containerization** | ![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white) ![ECR](https://img.shields.io/badge/AWS_ECR-FF9900?style=flat-square&logo=amazonaws&logoColor=white) |
| **Orchestration** | ![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat-square&logo=kubernetes&logoColor=white) ![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=flat-square&logo=argo&logoColor=white) ![nginx](https://img.shields.io/badge/nginx--ingress-009639?style=flat-square&logo=nginx&logoColor=white) |
| **IaC** | ![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat-square&logo=terraform&logoColor=white) |
| **CI/CD** | ![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat-square&logo=githubactions&logoColor=white) |
| **Cloud** | ![EC2](https://img.shields.io/badge/EC2-FF9900?style=flat-square&logo=amazonec2&logoColor=white) ![ALB](https://img.shields.io/badge/ALB-FF9900?style=flat-square&logo=awselasticloadbalancing&logoColor=white) ![NLB](https://img.shields.io/badge/NLB-FF9900?style=flat-square&logo=awselasticloadbalancing&logoColor=white) ![ECR](https://img.shields.io/badge/ECR-FF9900?style=flat-square&logo=amazonecr&logoColor=white) ![Route53](https://img.shields.io/badge/Route53-FF9900?style=flat-square&logo=amazonroute53&logoColor=white) ![SSM](https://img.shields.io/badge/SSM-FF9900?style=flat-square&logo=amazonaws&logoColor=white) ![IAM](https://img.shields.io/badge/IAM-FF9900?style=flat-square&logo=amazoniam&logoColor=white) |

---

## Project Structure

```
Kubernetes-SP/
├── Application/              # Django status page app + Dockerfile
│   └── Dockerfile            #   Multi-stage build (Node.js frontend + Python backend)
│
├── k8s/                      # Kubernetes manifests
│   ├── statuspage/           #   App Deployment, Service, Ingress, ConfigMap, Secrets
│   ├── postgres/             #   PostgreSQL StatefulSet + PersistentVolumeClaims
│   ├── redis/                #   Redis Deployment + Service
│   ├── ingress/              #   nginx-ingress controller configuration
│   └── argocd/               #   ArgoCD Application manifest (GitOps)
│
├── Terraform/                # AWS infrastructure as code
│   ├── modules/              #   Reusable modules: EC2, LB, ASG, SG, IAM
│   └── scripts/              #   Userdata scripts for kubeadm init and join
│
└── .github/
    └── workflows/
        └── CiDockerimage.yml            # CI pipeline: build -> test -> push to ECR
```

---

## How It Works

### 1. Infrastructure Provisioning (Terraform)

Terraform provisions all AWS infrastructure from code:

- **EC2 instances** - one master node and worker nodes via an Auto Scaling Group (ASG)
- **Load balancers** - ALB for HTTP/S traffic, NLB for TCP passthrough to the ingress controller
- **Security groups** - least-privilege rules for inter-node and external access
- **Route53** - DNS records pointing to the load balancer
- **IAM** - scoped roles for EC2 instance profiles (SSM access, ECR pull)

### 2. Cluster Initialisation (kubeadm)

`kubeadm init` runs on the master node via the EC2 userdata script. Worker nodes join using a token generated at init time. **Flannel** is deployed as the CNI for pod networking.

### 3. Application Deployment (Kubernetes Manifests)

The `k8s/` directory contains manifests for the full application stack:

| Workload | Kind | Notes |
|---|---|---|
| Django app | `Deployment` | 3 replicas, rolling update strategy |
| PostgreSQL | `StatefulSet` | Persistent volume for data durability |
| Redis | `Deployment` | Used for cache and django-rq job queue |
| nginx-ingress | `DaemonSet` / controller | Routes external traffic into the cluster |

### 4. CI Pipeline (GitHub Actions)

On every pull request to `main`, the pipeline:

1. Spins up **PostgreSQL** and **Redis** as service containers
2. **Builds** the multi-stage Docker image
3. Runs a **health check** against the running container
4. On success, **pushes the image to AWS ECR** tagged with the commit SHA (`$GITHUB_SHA`)

### 5. Continuous Delivery (ArgoCD)

ArgoCD is installed in the cluster and configured to watch this repository. When a new image tag is committed (or manifests change), ArgoCD automatically syncs the cluster to the desired state - no manual `kubectl apply` required.

---

## CI/CD Pipeline

```
Pull Request to main
        │
        ▼
┌─────────────────────────────────────────────────────┐
│  GitHub Actions                                     │
│                                                     │
│  1. Start service containers (PostgreSQL, Redis)    │
│  2. Build Docker image (multi-stage)                │
│  3. Health check - GET /healthz -> 200 OK           │
│  4. Push to ECR  ->  Hi9841/status-page:<sha>       │
└─────────────────────────────────────────────────────┘
        │
        ▼
  ECR image available
        │
        ▼
┌─────────────────────────────────────────────────────┐
│  ArgoCD (GitOps)                                    │
│                                                     │
│  Watches repo -> detects manifest/tag change        │
│  Syncs cluster to desired state automatically       │
└─────────────────────────────────────────────────────┘
        │
        ▼
  Live on Kubernetes cluster
```

---

## Key Features

- **Incident & maintenance management** - create, update, and resolve incidents with full status tracking
- **REST API** - programmatic access for external integrations
- **Background job processing** - async tasks via Redis + django-rq (e.g. email notifications)
- **Multi-factor authentication** - OTP and YubiKey support
- **Email notifications** - subscriber alerts on status changes
- **External provider integration** - UptimeRobot sync for automated uptime monitoring

---

## Getting Started

### Prerequisites

- AWS account with appropriate IAM permissions
- Terraform >= 1.0
- `kubectl` configured
- AWS CLI authenticated

### 1. Provision Infrastructure

```bash
cd Terraform/
terraform init
terraform plan
terraform apply
```

### 2. Initialise the Cluster

kubeadm init runs automatically via the EC2 userdata script on the master node. To retrieve the join command:

```bash
ssh ec2-user@<master-ip> "sudo kubeadm token create --print-join-command"
```

### 3. Deploy the Application

```bash
kubectl apply -f k8s/ingress/
kubectl apply -f k8s/postgres/
kubectl apply -f k8s/redis/
kubectl apply -f k8s/statuspage/
kubectl apply -f k8s/argocd/
```

### 4. Configure GitHub Actions

Set the following secrets in your GitHub repository:

| Secret | Description |
|---|---|
| `AWS_REGION` | Target AWS region |
| `ECR_REPOSITORY` | ECR repository URI |
| `AWS_ROLE_ARN` | IAM role ARN for OIDC federation |
