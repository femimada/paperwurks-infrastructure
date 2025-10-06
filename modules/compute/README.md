# Compute Module

## Purpose

Provisions and manages the container orchestration infrastructure for running Paperwurks application workloads. This module creates an ECS cluster with associated services, load balancing, and auto-scaling capabilities.

## What This Module Creates

- **ECS Cluster**: Container orchestration platform
- **ECS Services**: Long-running application services (backend API, worker processes)
- **Application Load Balancer**: HTTP/HTTPS traffic distribution
- **Target Groups**: Health-checked routing to containers
- **Auto Scaling**: Dynamic capacity management based on demand
- **IAM Roles**: Permissions for task execution and application runtime
- **CloudWatch Log Groups**: Centralized application logging

## When To Use

Use this module when you need to:

- Run containerized applications in a managed environment
- Deploy web APIs that need load balancing
- Run background worker processes
- Scale application capacity automatically
- Manage multiple microservices in a single environment

## What This Module Does NOT Do

- Build or store container images (use ECR separately)
- Manage databases or data stores
- Handle application code deployment (CI/CD manages that)
- Configure application-specific environment variables
- Manage SSL certificates (handled at ALB level)

## Dependencies

**Required Inputs:**

- VPC ID and subnet IDs (from networking module)
- Security group IDs (from networking module)
- Container image repository URLs (from ECR setup)

**AWS Services Used:**

- Amazon ECS (Elastic Container Service)
- Amazon EC2 (for compute instances) or AWS Fargate
- Elastic Load Balancing (Application Load Balancer)
- Amazon CloudWatch (logs and metrics)
- AWS IAM (permissions)

## Key Decisions This Module Makes

- **Launch Type**: EC2-based (cost-optimized) vs Fargate (simplified management)
- **Service Count**: Number of backend and worker services
- **Instance Types**: Compute capacity sizing
- **Health Check Configuration**: How services verify application health
- **Logging Strategy**: Where container logs are sent

## Cost Implications

**Primary Cost Drivers:**

- EC2 instances running 24/7 (or Fargate task hours)
- Application Load Balancer (hourly + LCU charges)
- Data transfer between AZs
- CloudWatch log ingestion and storage

**Typical Monthly Cost Range:**

- Dev: £60-90 (1-2 instances, basic ALB)
- Staging: £80-120 (2-3 instances, moderate traffic)
- Production: £250-400 (4-6 instances, HA, auto-scaling)

## Security Considerations

**What This Module Protects:**

- Container workloads run in private subnets (no direct internet access)
- IAM roles enforce least-privilege access
- Security groups restrict network traffic
- Load balancer provides SSL termination point

**What You Must Configure:**

- Environment-specific secrets (in Secrets Manager)
- Container image vulnerability scanning
- Network access policies
- Log retention and monitoring

## Typical Usage Pattern

1. Networking module creates VPC and subnets
2. **This module** creates ECS cluster and services
3. CI/CD pipeline builds container images
4. CI/CD pipeline updates ECS task definitions
5. ECS services automatically deploy new containers
6. Load balancer routes traffic to healthy containers

## Integration Points

**Consumes:**

- VPC configuration (networking module)
- Security groups (networking module)
- Container images (ECR repositories)

**Provides:**

- ECS cluster ARN (for deployments)
- Service names (for CI/CD)
- Load balancer DNS (for routing)
- IAM role ARNs (for permission grants)

## Operational Considerations

**Scaling Behavior:**

- Services scale based on CPU/memory thresholds
- Minimum capacity prevents service interruption
- Maximum capacity controls costs
- Scale-in actions are slower than scale-out (safety)

**Deployment Strategy:**

- Rolling updates with health checks
- Configurable deployment circuit breaker
- Zero-downtime deployments when healthy

**Monitoring Needs:**

- Task start/stop events
- Service health status
- Target health checks
- Auto-scaling activities

## Environment Differences

| Aspect            | Dev       | Staging   | Production |
| ----------------- | --------- | --------- | ---------- |
| **Min Instances** | 1         | 1         | 2          |
| **Max Instances** | 3         | 3         | 6          |
| **Instance Type** | t3.medium | t3.medium | t3.large   |
| **Health Checks** | Relaxed   | Moderate  | Strict     |
| **Log Retention** | 7 days    | 14 days   | 30 days    |

## Common Modifications

**To reduce costs:**

- Use Fargate Spot for worker tasks
- Reduce minimum instance count
- Lower health check frequency
- Shorter log retention

**To improve reliability:**

- Increase minimum instances
- Enable cross-zone load balancing
- Stricter health checks
- Connection draining enabled

**To improve performance:**

- Larger instance types
- More instances
- Target tracking auto-scaling
- Enhanced monitoring

## Related Modules

- **networking**: Provides VPC and subnets
- **database**: Applications connect to RDS
- **storage**: Applications read/write to S3
- **monitoring**: Aggregates logs and metrics
