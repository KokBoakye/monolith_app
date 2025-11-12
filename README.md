# 🧱 Monolith FastAPI Application — AWS ECS + Terraform + GitHub Actions

This project demonstrates deploying a **monolithic FastAPI application** to **AWS ECS Fargate**, using:
- **Terraform** for infrastructure provisioning
- **Docker** for containerization
- **Amazon ECR** for image storage
- **GitHub Actions** for CI/CD automation

It’s a single-service architecture that combines user, order, and service logic in one codebase — ideal for smaller systems or early MVP stages before splitting into microservices.

---

## 🚀 Architecture Overview

**Tech Stack**
| Layer | Technology |
|-------|-------------|
| Application | FastAPI |
| Infrastructure | AWS ECS Fargate |
| Networking | AWS VPC + ALB + NAT Gateway |
| CI/CD | GitHub Actions |
| IaC | Terraform |
| Container Registry | Amazon ECR |

**Flow**
1. Developer pushes code to `main` branch → GitHub Actions triggers.  
2. GitHub Actions:
   - Builds Docker image for FastAPI app  
   - Pushes image to **Amazon ECR**  
   - Runs Terraform to deploy/update **AWS ECS Service**  
3. Application runs behind an **Application Load Balancer (ALB)**.

---

## 🏗️ Project Structure

monolith_app/
├── app.py # FastAPI main entry point
├── database.py # Database connection logic
├── models.py # ORM models / schema
├── services.py # Business logic layer
├── requirements.txt # Python dependencies
├── Dockerfile # Docker image instructions
├── terraform/ # Terraform IaC definitions
│ ├── backend.tf
│ ├── main.tf
│ ├── provider.tf
│ ├── outputs.tf
│ └── security.tf
└── .github/workflows/
└── deploy.yml # GitHub Actions CI/CD workflow

---

## ⚙️ Local Development

### 1️⃣ Set up environment
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt


2️⃣ Run locally
uvicorn app:app --reload --host 0.0.0.0 --port 8000
Visit 👉 http://localhost:8000/docs


🐳 Docker Build and Test Locally
docker build -t monolith-app .
docker run -p 8000:8000 monolith-app


☁️ Deployment (via GitHub Actions)
🔄 Automatic Deployment
Whenever you push to the main branch:
GitHub Actions builds and tags a new Docker image
Pushes it to Amazon ECR
Applies Terraform to provision/update the AWS infrastructure
Forces a new ECS deployment automatically


🧩 Environment Variables / Secrets in GitHub
In your GitHub repository → Settings → Secrets and variables → Actions, define:
Secret	Description
AWS_ROLE_ARN	IAM Role ARN for GitHub OIDC authentication
ECR_REGISTRY	Your Amazon ECR registry URL (e.g., 123456789012.dkr.ecr.eu-north-1.amazonaws.com)
AWS_REGION	AWS region, e.g., eu-north-1


⚙️ Terraform Resources
Terraform provisions:
VPC, Public/Private Subnets
Internet + NAT Gateways
Application Load Balancer (ALB)
ECS Cluster + Task Definition
Security Groups
ECR Repository
Apply manually (optional):
cd terraform
terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -auto-approve


🧠 Troubleshooting Guide
Issue	Cause	Solution
CannotPullContainerError	Image not found in ECR	Ensure ECR repo exists and image tag matches
504 Gateway Timeout	ECS service not reachable	Verify ALB health checks and security groups
ALB targets “unhealthy”	Wrong health check path	Add / or /health endpoint in FastAPI
Task stopping unexpectedly	Low memory or port mismatch	Check ECS task logs and ensure correct port mapping
Terraform errors	Missing permissions	Verify AWS_ROLE_ARN and IAM trust policy for GitHub OIDC


🧾 Outputs
After successful deployment:
alb_dns_name = monolith-app-alb-123456789.eu-north-1.elb.amazonaws.com
Visit your live app:
http://<alb_dns_name>/docs


🧹 Cleanup
To destroy all AWS resources:
cd terraform
terraform destroy -auto-approve


✅ Summary
Feature	Description
Framework	FastAPI
Infra	AWS ECS Fargate
IaC	Terraform
CI/CD	GitHub Actions
Scalable	Easily upgradeable to microservices architecture


👤 Author
Kwabena Okyere Boakye