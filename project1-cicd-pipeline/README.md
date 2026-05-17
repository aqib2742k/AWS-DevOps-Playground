# End-to-End CI/CD Pipeline for Microservices 🚀

![CI/CD](https://img.shields.io/badge/CI%2FCD-Jenkins-blue)
![Docker](https://img.shields.io/badge/Container-Docker-blue)
![Kubernetes](https://img.shields.io/badge/Orchestration-Kubernetes-blue)
![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-orange)
![AWS](https://img.shields.io/badge/Cloud-AWS-orange)

## Architecture Overview

```
Developer Push
      │
      ▼
  GitHub Repo
      │
      ▼
  Jenkins CI
  ├── Build (Maven/Docker)
  ├── Test
  ├── SonarQube Analysis
  └── Push Image → Amazon ECR
            │
            ▼
       ArgoCD (GitOps)
            │
            ▼
      Amazon EKS Cluster
      ├── Deployment
      ├── Service
      └── Ingress (Nginx)
```

## Tech Stack

| Tool | Purpose |
|------|---------|
| Jenkins | CI - Build, Test, Push |
| SonarQube | Static Code Analysis |
| Docker | Containerization |
| Amazon ECR | Private Container Registry |
| ArgoCD | GitOps Continuous Delivery |
| Amazon EKS | Kubernetes Cluster |
| Helm | Kubernetes Package Manager |
| Nginx Ingress | Ingress Controller |

## Project Structure

```
├── jenkins/
│   └── Jenkinsfile              # Pipeline definition
├── docker/
│   └── Dockerfile               # App containerization
├── kubernetes/
│   ├── deployment.yaml          # K8s Deployment manifest
│   ├── service.yaml             # K8s Service manifest
│   └── ingress.yaml             # Nginx Ingress config
├── sonarqube/
│   └── sonar-project.properties # SonarQube config
└── docs/
    └── setup.md                 # Setup instructions
```

## Prerequisites

- AWS Account with EKS cluster running
- Jenkins server (EC2 instance)
- SonarQube server
- ArgoCD installed on EKS
- Amazon ECR repository

## Setup Guide

### 1. Jenkins Setup
```bash
# Install Jenkins on EC2
sudo apt update
sudo apt install openjdk-17-jdk -y
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins -y
sudo systemctl start jenkins
```

### 2. Required Jenkins Plugins
- Docker Pipeline
- AWS Credentials
- SonarQube Scanner
- Kubernetes CLI

### 3. Configure AWS Credentials in Jenkins
- Go to Jenkins → Manage Jenkins → Credentials
- Add AWS Access Key ID and Secret Access Key

### 4. ArgoCD Setup
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

### 5. Connect ArgoCD to GitHub Repo
- Login to ArgoCD UI
- Add repository
- Create Application pointing to `kubernetes/` folder

## Pipeline Flow

1. Developer pushes code to GitHub
2. Jenkins webhook triggers pipeline
3. Jenkins builds Docker image
4. SonarQube scans code for quality/security
5. Docker image pushed to Amazon ECR
6. Kubernetes manifests updated with new image tag
7. ArgoCD detects change in GitHub
8. ArgoCD syncs EKS cluster to desired state
9. Application deployed/updated on EKS

## Key Outcomes

- Reduced manual deployment time by ~70%
- Automated code quality checks on every commit
- Zero-downtime deployments via rolling updates
- Full GitOps workflow — Git is single source of truth
