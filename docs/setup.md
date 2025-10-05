# Paperwurks Cloud Infrastructure & Deployment Strategy

## Overview

The Paperwurks cloud environment is managed through a two-repository model:

| Repository           | Owner             | Purpose                                | IAM Role      |
| -------------------- | ----------------- | -------------------------------------- | ------------- |
| `paperwurks/infra`   | DevOps Team       | Manages cloud infrastructure           | `infra-role`  |
| `paperwurks/backend` | Core Backend Team | Manages application code & deployments | `deploy-role` |

This split ensures a clean separation of concerns:

- **Infrastructure lifecycle** managed by DevOps
- **Application lifecycle** managed by developers

## Repository Responsibilities

### 1. paperwurks/infra Repository

**Purpose:**

- Owns all Terraform configurations for AWS
- Manages shared resources (IAM, ECR, S3, networking)
- Defines environment-specific infrastructure (dev, staging, prod)
- Enforces security and compliance policies

#### IAM Roles

**infra-role**

- Used by `paperwurks/infra` CI/CD pipeline
- **Permissions:** Create/update/destroy AWS infrastructure, manage Terraform state, manage IAM roles
- **✅ Allowed:** IAM, ECS, RDS, S3, CloudFront, VPC, Secrets Manager, KMS
- **🚫 Restricted:** No ECR push/pull, no application deployments

**deploy-role**

- Used by `paperwurks/backend` CI/CD pipeline
- **Permissions:** Deploy container images to existing ECS services
- **✅ Allowed:** ECR push/pull, ECS task definitions, CloudWatch Logs read, SSM read
- **🚫 Restricted:** No infrastructure provisioning, no Terraform access

### 2. paperwurks/backend Repository

**Purpose:**

- Contains application code and Docker configurations
- Builds and pushes container images to ECR
- Deploys to pre-provisioned ECS services

**Deployment Flow:**

1. Developer pushes code → Triggers CI pipeline
2. Build & test → Linting, testing, static analysis
3. Docker build → Image tagged (e.g., `backend:staging-<sha>`)
4. AWS auth → GitHub Actions assumes `deploy-role` via OIDC
5. Push to ECR → Image pushed to environment's ECR
6. Deploy to ECS → ECS service updated via task definition

## Security & Access Model

| Role          | Trust Boundary         | Permissions Scope              | CI/CD Source         |
| ------------- | ---------------------- | ------------------------------ | -------------------- |
| `infra-role`  | Organization → DevOps  | Full infrastructure management | `paperwurks/infra`   |
| `deploy-role` | Organization → Backend | Limited ECS + ECR              | `paperwurks/backend` |

**OIDC Trust Policy:**
Condition includes repository and branch restrictions for GitHub Actions.

## Terraform Integration

**Structure:**

- **Shared setup (`setup/`):** IAM roles, ECR, S3, KMS, networking
- **Environment modules (`envs/`):** ECS services, RDS, environment-specific resources

Shared resources created once, environment resources created per environment using `infra-role`.

## Role Interaction

Roles defined in shared setup and exported as outputs for consumption by CI/CD workflows and environment modules.

**Consumed by:**

- CI/CD workflows (via Terraform output or SSM Parameter Store)
- Environment modules that need role references
