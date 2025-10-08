# Compute Module - AWS Fargate

## Purpose

Provisions and manages **AWS Fargate serverless container** infrastructure for running Paperwurks application workloads. This module creates an ECS cluster with Fargate services, load balancing, and application logging.

**Version**: 2.0 (Fargate-only)  
**Previous Version**: 1.0 used EC2-based ECS - **DEPRECATED**

## What This Module Creates

- **ECS Cluster**: Container orchestration platform (Fargate launch type only)
- **ECS Services**: Long-running application services (backend API, worker processes)
- **Application Load Balancer**: HTTP/HTTPS traffic distribution (in public subnets)
- **Target Groups**: Health-checked routing to Fargate tasks (type: `ip`)
- **IAM Roles**: Task execution role and task role for application permissions
- **CloudWatch Log Groups**: Centralized application logging

## Architecture Change (v2.0)

**REMOVED in v2.0**:

- EC2 instances
- Auto Scaling Groups (ASG)
- Launch Templates
- EC2 Capacity Providers
- EC2 instance profiles

**ADDED in v2.0**:

- AWS Fargate launch type
- `awsvpc` network mode (each task gets dedicated ENI)
- IP-based target groups (not instance-based)
- Simplified IAM (no instance profiles needed)

## When To Use

Use this module when you need to:

- Run containerized applications without managing servers
- Deploy web APIs that need load balancing
- Run background worker processes
- Scale application capacity automatically (task-level scaling)
- Minimize operational overhead

## What This Module Does NOT Do

- Build or store container images (use ECR separately - managed in `setup/`)
- Manage databases or data stores (use database module)
- Handle application code deployment (CI/CD manages that)
- Configure application-specific environment variables (passed via task definitions)
- Manage SSL certificates (handled at ALB level or CloudFront)

## Dependencies

**Required Inputs:**

- VPC ID and subnet IDs (from networking module)
- Security group IDs (from networking module)
- Container image repository URLs (from ECR setup)

**AWS Services Used:**

- Amazon ECS (Elastic Container Service) - Fargate launch type
- AWS Fargate (serverless compute)
- Elastic Load Balancing (Application Load Balancer)
- Amazon CloudWatch (logs and metrics)
- AWS IAM (task permissions)

## Key Decisions This Module Makes

- **Launch Type**: Fargate (serverless, no server management)
- **Network Mode**: `awsvpc` (dedicated ENI per task)
- **Service Count**: Number of backend and worker tasks
- **Task Sizing**: CPU and memory allocation per task
- **Health Check Configuration**: How services verify application health
- **Logging Strategy**: Where container logs are sent

## Cost Implications

### Fargate Pricing Model

**You pay for**:

- vCPU-hours (per vCPU per hour tasks run)
- GB-hours (per GB memory per hour tasks run)
- No idle costs when tasks aren't running

**Primary Cost Drivers:**

- Task CPU allocation (vCPU)
- Task memory allocation (GB)
- Number of running tasks
- Task uptime (billed per second, 1-minute minimum)
- Application Load Balancer (fixed + LCU charges)
- Data transfer between AZs
- CloudWatch log ingestion and storage

### Typical Monthly Cost Range

| Environment | Backend Tasks  | Worker Tasks      | ALB | Logs | Total       |
| ----------- | -------------- | ----------------- | --- | ---- | ----------- |
| **Dev**     | 1x 0.5vCPU/1GB | 1x 0.25vCPU/512MB | £18 | £5   | **£20-25**  |
| **Staging** | 2x 0.5vCPU/1GB | 1x 0.25vCPU/512MB | £18 | £5   | **£25-30**  |
| **Prod**    | 2x 1vCPU/2GB   | 2x 0.5vCPU/1GB    | £18 | £10  | **£80-100** |

**Cost Comparison**:

- **Fargate Dev**: £20-25/month
- **EC2 Dev (previous)**: £25-30/month (1x t3.medium 24/7)
- **Savings**: 15-20%

### Cost Optimization Tips

**To reduce costs:**

- Use Fargate Spot for non-critical workloads (50-70% discount)
- Right-size tasks (don't over-allocate CPU/memory)
- Scale down tasks during off-hours (dev/staging)
- Shorter log retention periods
- Use VPC endpoints to reduce NAT gateway costs

**To improve performance (increases cost):**

- Larger task sizes (more vCPU/memory)
- More tasks for higher availability
- Longer log retention

## Security Considerations

**What This Module Protects:**

- Fargate tasks run in private subnets (no direct internet access)
- IAM task roles enforce least-privilege access
- Security groups restrict network traffic to known sources
- Load balancer provides SSL termination point
- Each task has isolated network namespace (awsvpc mode)

**What You Must Configure:**

- Application-level security (authentication, authorization)
- Environment-specific secrets (in Secrets Manager)
- Container image vulnerability scanning (in CI/CD)
- Network access policies (security group rules)
- Log retention and access policies

## Typical Usage Pattern

1. **Networking module** creates VPC and subnets
2. **This module** creates ECS cluster and Fargate services
3. **CI/CD pipeline** builds container images and pushes to ECR
4. **CI/CD pipeline** updates ECS task definitions with new image tags
5. **ECS** automatically deploys new Fargate tasks with updated images
6. **Load balancer** routes traffic to healthy tasks

## Integration Points

**Consumes:**

- VPC configuration (networking module)
- Security groups (networking module)
- Container images (ECR repositories from setup)

**Provides:**

- ECS cluster ARN (for CI/CD deployments)
- Service names (for CI/CD updates)
- Load balancer DNS (for routing/DNS configuration)
- IAM role ARNs (for granting additional permissions)

## Operational Considerations

### Fargate Task Lifecycle

**Deployment Process**:

1. New task definition registered
2. New tasks launched with updated definition
3. Health checks verify new tasks are healthy
4. Traffic shifted to new tasks
5. Old tasks drained and stopped
6. **Zero downtime** (with proper health checks)

**Scaling Behavior**:

- Tasks scale instantly (no instance warmup needed)
- Minimum capacity prevents service interruption
- Maximum capacity controls costs
- Scale-in actions are slower than scale-out (safety)

**Deployment Strategy**:

- Rolling updates with circuit breaker enabled
- 50% minimum healthy during deployment
- 200% maximum capacity during deployment
- Automatic rollback on health check failures

### Monitoring Needs

**ECS Metrics**:

- Task start/stop events
- Service health status
- Task CPU/memory utilization
- Running task count

**ALB Metrics**:

- Target health checks
- Request count and latency
- HTTP status codes (4xx, 5xx)
- Active connection count

## Environment Differences

| Aspect             | Dev            | Staging        | Production    |
| ------------------ | -------------- | -------------- | ------------- |
| **Backend Tasks**  | 1              | 2              | 2-4           |
| **Backend CPU**    | 512 (.5 vCPU)  | 512 (.5 vCPU)  | 1024 (1 vCPU) |
| **Backend Memory** | 1024 MB        | 1024 MB        | 2048 MB       |
| **Worker Tasks**   | 1              | 1              | 2             |
| **Worker CPU**     | 256 (.25 vCPU) | 256 (.25 vCPU) | 512 (.5 vCPU) |
| **Worker Memory**  | 512 MB         | 512 MB         | 1024 MB       |
| **Health Checks**  | Relaxed (60s)  | Moderate (30s) | Strict (15s)  |
| **Log Retention**  | 7 days         | 14 days        | 30 days       |

## Valid Fargate CPU/Memory Combinations

⚠️ **IMPORTANT**: Not all CPU/memory combinations are valid!

| CPU (vCPU) | Valid Memory (MB)                        |
| ---------- | ---------------------------------------- |
| 256 (.25)  | 512, 1024, 2048                          |
| 512 (.5)   | 1024, 2048, 3072, 4096                   |
| 1024 (1)   | 2048, 3072, 4096, 5120, 6144, 7168, 8192 |
| 2048 (2)   | 4096-16384 (1GB increments)              |
| 4096 (4)   | 8192-30720 (1GB increments)              |

**Example Error**:

```
Error: Invalid CPU/memory combination
cpu=512, memory=512 is not valid
Valid memory values for cpu=512: 1024, 2048, 3072, 4096
```

## Common Issues & Fixes

### Issue: Tasks Stuck in PENDING

**Symptoms**: Tasks never reach RUNNING state

**Common Causes**:

1. Invalid CPU/memory combination
2. Subnets have no NAT gateway route
3. Security groups blocking traffic
4. No available IP addresses in subnet
5. ECR image pull failures

**Debug**:

```bash
# Check task stopped reason
aws ecs describe-tasks \
  --cluster paperwurks-dev-cluster \
  --tasks <task-id> \
  --query 'tasks[0].stoppedReason'

# Check for ENI issues
aws ec2 describe-network-interfaces \
  --filters "Name=status,Values=pending"
```

### Issue: ALB Health Checks Failing

**Symptoms**: All targets show unhealthy

**Common Causes**:

1. Health check path doesn't exist (e.g., `/health/`)
2. Security group doesn't allow ALB → ECS traffic
3. Container not listening on configured port
4. Application takes too long to start

**Debug**:

```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn <arn>

# Check ECS task logs
aws logs tail /ecs/dev-paperwurks-backend --follow

# Verify security group rules
aws ec2 describe-security-groups \
  --group-ids <ecs-sg-id>
```

### Issue: Tasks Can't Reach Internet

**Symptoms**: ECR pulls fail, external API calls timeout

**Common Causes**:

1. Private subnet has no NAT gateway route
2. NAT gateway not attached to public subnet
3. Route table associations incorrect
4. VPC endpoint misconfigured

**Debug**:

```bash
# Check route tables
aws ec2 describe-route-tables \
  --filters "Name=vpc-id,Values=<vpc-id>"

# Check NAT gateway status
aws ec2 describe-nat-gateways \
  --filter "Name=vpc-id,Values=<vpc-id>"
```

## Common Modifications

### To Reduce Costs

```hcl
# Use smaller task sizes
backend_cpu    = 256  # Down from 512
backend_memory = 512  # Down from 1024

# Reduce task count
backend_desired_count = 1  # Down from 2

# Use Fargate Spot (50-70% discount)
capacity_provider_strategy {
  capacity_provider = "FARGATE_SPOT"
  weight            = 100
}
```

### To Improve Reliability

```hcl
# Increase task count
backend_desired_count = 3  # Up from 2

# Add auto-scaling
resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${cluster}/${service}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Stricter health checks
health_check {
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout             = 3
  interval            = 10
}
```

### To Improve Performance

```hcl
# Larger task sizes
backend_cpu    = 1024  # 1 vCPU
backend_memory = 2048  # 2 GB

# More tasks
backend_desired_count = 4

# Enable Container Insights
cluster_settings {
  name  = "containerInsights"
  value = "enabled"
}
```

## Related Modules

- **networking**: Provides VPC, subnets, and security groups
- **database**: Applications connect to RDS from Fargate tasks
- **storage**: Applications read/write to S3 buckets
- **monitoring**: Aggregates logs and metrics from tasks

## Useful Commands

```bash
# List running tasks
aws ecs list-tasks --cluster paperwurks-dev-cluster

# Describe a task
aws ecs describe-tasks \
  --cluster paperwurks-dev-cluster \
  --tasks <task-id>

# View task logs
aws logs tail /ecs/dev-paperwurks-backend --follow --since 5m

# Force new deployment (pulls latest image)
aws ecs update-service \
  --cluster paperwurks-dev-cluster \
  --service dev-paperwurks-backend \
  --force-new-deployment

# Stop a specific task (for debugging)
aws ecs stop-task \
  --cluster paperwurks-dev-cluster \
  --task <task-id> \
  --reason "Manual debug"
```

## Migration Notes (EC2 → Fargate)

If you're migrating from the previous EC2-based version:

**Breaking Changes**:

- All EC2 instances will be terminated
- ASG and launch templates will be deleted
- Task definitions must use `awsvpc` network mode
- Target groups must use `ip` target type (not `instance`)
- IAM instance profiles are no longer needed

**Migration Steps**:

1. Backup Terraform state
2. Update module configuration (remove EC2 variables)
3. Run `terraform plan` to review changes
4. Expect 2-5 minutes downtime during migration
5. Verify services are running after apply

**Rollback**: Not supported. EC2 and Fargate are incompatible architectures.

## Support

- **Module Issues**: #infrastructure Slack channel
- **AWS Fargate Docs**: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html
- **ECS Best Practices**: https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/

---

**Maintained By**: DevOps Team  
**Last Updated**: October 2025  
**Version**: 2.0 (Fargate)
