# Infrastructure as Code (IaC) — High Availability AWS Architecture 🏗️

![Terraform](https://img.shields.io/badge/IaC-Terraform-purple)
![AWS](https://img.shields.io/badge/Cloud-AWS-orange)
![Prometheus](https://img.shields.io/badge/Monitoring-Prometheus-red)
![Grafana](https://img.shields.io/badge/Dashboard-Grafana-orange)

## Architecture Overview

```
                        Internet
                           │
                    ┌──────▼──────┐
                    │     ALB     │  (Application Load Balancer)
                    └──────┬──────┘
                           │
              ┌────────────▼────────────┐
              │                         │
        ┌─────▼─────┐           ┌───────▼─────┐
        │  Public   │           │   Public    │
        │ Subnet AZ1│           │ Subnet AZ2  │
        └─────┬─────┘           └──────┬──────┘
              │                        │
        ┌─────▼─────┐           ┌──────▼──────┐
        │  Private  │           │   Private   │
        │ Subnet AZ1│           │ Subnet AZ2  │
        │  (EC2/ASG)│           │  (EC2/ASG)  │
        └───────────┘           └─────────────┘
              │                        │
        ┌─────▼────────────────────────▼──────┐
        │           S3 + DynamoDB             │
        │        (Terraform State)            │
        └─────────────────────────────────────┘
```

## Tech Stack

| Tool | Purpose |
|------|---------|
| Terraform | Infrastructure provisioning |
| AWS VPC | Network isolation |
| EC2 + ASG | Auto-scaling compute |
| ALB | Load balancing |
| S3 + DynamoDB | Remote state & locking |
| Prometheus | Metrics collection |
| Grafana | Monitoring dashboards |

## Project Structure

```
├── terraform/
│   ├── environments/
│   │   └── prod/
│   │       ├── main.tf          # Root module calls
│   │       ├── variables.tf     # Environment variables
│   │       ├── outputs.tf       # Output values
│   │       └── backend.tf       # S3 remote state config
│   └── modules/
│       ├── vpc/                 # VPC, Subnets, IGW, NAT
│       ├── ec2/                 # EC2 launch template
│       ├── alb/                 # Application Load Balancer
│       └── asg/                 # Auto Scaling Group
├── monitoring/
│   ├── prometheus/
│   │   └── prometheus.yml       # Prometheus config
│   └── grafana/
│       └── dashboard.json       # Grafana dashboard
└── docs/
    └── setup.md
```

## How to Deploy

### 1. Prerequisites
```bash
# Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Configure AWS CLI
aws configure
```

### 2. Create S3 Bucket and DynamoDB for Remote State
```bash
# Create S3 bucket for state
aws s3api create-bucket \
    --bucket your-terraform-state-bucket \
    --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket your-terraform-state-bucket \
    --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
    --table-name terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST
```

### 3. Deploy Infrastructure
```bash
cd terraform/environments/prod

terraform init
terraform plan
terraform apply
```

### 4. Destroy Infrastructure
```bash
terraform destroy
```

## Key Features

- **Modular design** — reusable modules for VPC, EC2, ALB, ASG
- **Remote state** — S3 backend with DynamoDB locking prevents drift
- **Multi-AZ** — resources spread across 2 Availability Zones
- **Auto Scaling** — ASG scales in/out based on CPU utilization
- **Observability** — Prometheus scrapes metrics, Grafana visualizes
