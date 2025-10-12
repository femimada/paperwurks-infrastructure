# ElastiCache Redis Module

## Purpose

Provisions and manages AWS ElastiCache Redis cluster for use as a Celery broker and caching layer. Provides high-availability Redis with automatic failover, encryption, and monitoring.

## What This Module Creates

- **ElastiCache Replication Group**: Redis cluster with primary and replica nodes
- **Subnet Group**: Network isolation for Redis cluster
- **Security Group**: Firewall rules limiting access to ECS tasks only
- **Parameter Group**: Redis 7.1 configuration optimized for Celery
- **CloudWatch Log Groups**: Slow query and engine logs
- **SSM Parameters**: Connection strings and credentials stored securely

## Features

### Environment-Specific Configuration

| Environment | Node Type | Cluster Mode | Multi-AZ | Replicas | Cost/Month |
| ----------- | --------- | ------------ | -------- | -------- | ---------- |
| Dev         | t4g.micro | Disabled     | No       | 0        | ~£10       |
| Staging     | t4g.micro | Disabled     | No       | 0        | ~£10       |
| Production  | t4g.small | Enabled      | Yes      | 1        | ~£40       |

### Security Features

- **Encryption at Rest**: All data encrypted using AWS KMS
- **Encryption in Transit**: TLS 1.2+ for all connections
- **Authentication**: Redis AUTH token required
- **Network Isolation**: Deployed in private subnets only
- **Security Groups**: Access restricted to ECS tasks

### High Availability (Production)

- **Multi-AZ Deployment**: Nodes spread across availability zones
- **Automatic Failover**: Promotes replica on primary failure
- **Read Replicas**: 1 replica for read scaling
- **Cluster Mode**: Horizontal scaling capability

## Usage

```hcl
module "elasticache" {
  source = "../../modules/elasticache"

  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.networking.vpc_id
  private_subnet_ids     = module.networking.private_subnet_ids
  ecs_security_group_id  = module.networking.ecs_security_group_id

  # Production: cluster mode enabled
  cluster_mode_enabled   = var.environment == "prod"

  # Authentication token (generate securely)
  auth_token             = random_password.redis_auth_token.result

  # Optional: customize maintenance windows
  maintenance_window     = "sun:05:00-sun:06:00"
  snapshot_window        = "03:00-04:00"
  snapshot_retention_limit = var.environment == "prod" ? 7 : 3
}

# Generate secure auth token
resource "random_password" "redis_auth_token" {
  length  = 32
  special = false
}
```

## Outputs

Key outputs for application integration:

- `primary_endpoint_address`: Primary write endpoint
- `reader_endpoint_address`: Read-only endpoint (with replicas)
- `configuration_endpoint_address`: Cluster mode endpoint
- `redis_url_parameter_name`: SSM parameter with full connection URL

## Application Integration

### Celery Configuration

```python
# settings.py
import boto3

# Fetch Redis URL from SSM Parameter Store
ssm = boto3.client('ssm', region_name='eu-west-2')
redis_url = ssm.get_parameter(
    Name=f'/paperwurks/{ENVIRONMENT}/redis/url',
    WithDecryption=True
)['Parameter']['Value']

# Celery configuration
CELERY_BROKER_URL = redis_url
CELERY_RESULT_BACKEND = redis_url
CELERY_BROKER_USE_SSL = {
    'ssl_cert_reqs': 'required',
    'ssl_ca_certs': '/etc/ssl/certs/ca-certificates.crt'
}
```

### Django Cache Configuration

```python
# settings.py
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': redis_url,
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            'CONNECTION_POOL_KWARGS': {
                'ssl_cert_reqs': 'required'
            }
        }
    }
}
```

## Monitoring

### CloudWatch Metrics

Automatic monitoring includes:

- CPU utilization
- Memory usage
- Network throughput
- Cache hit/miss ratio
- Evictions
- Replication lag

### CloudWatch Alarms (Add to monitoring module)

```hcl
resource "aws_cloudwatch_metric_alarm" "redis_cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-redis-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Redis CPU usage is above 75%"

  dimensions = {
    ReplicationGroupId = module.elasticache.replication_group_id
  }
}
```

## Cost Optimization

### Development/Staging

- Single t4g.micro node (~£10/month)
- No replicas
- Single-AZ deployment
- 3-day snapshot retention

### Production

- Primary + 1 replica (~£40/month)
- Multi-AZ with automatic failover
- 7-day snapshot retention
- CloudWatch detailed monitoring

### Cost Saving Tips

- Use t4g (Graviton2) instances for 20% savings vs t3
- Reduce snapshot retention for non-prod
- Consider Reserved Instances for production (40% savings)

## Maintenance

### Backup Strategy

- Automatic daily snapshots during snapshot window
- Point-in-time recovery capability
- Manual snapshots before major changes

### Upgrade Process

1. Test new Redis version in dev environment
2. Promote to staging for validation
3. Schedule production upgrade during maintenance window
4. Automatic minor version upgrades enabled

### Failover Testing

```bash
# Trigger manual failover (production)
aws elasticache test-failover \
  --replication-group-id paperwurks-prod-redis \
  --node-group-id 0001
```

## Troubleshooting

### Connection Issues

```bash
# Check security group rules
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw redis_security_group_id)

# Verify ECS task can reach Redis
aws ecs execute-command --cluster prod-paperwurks-cluster \
  --task <task-id> --container backend \
  --command "redis-cli -h <endpoint> -p 6379 --tls -a <token> ping"
```

### Performance Issues

```bash
# Check Redis INFO
redis-cli -h <endpoint> -p 6379 --tls -a <token> INFO

# Monitor slow queries
aws logs tail /aws/elasticache/paperwurks-prod/redis/slow-log --follow
```

## Security Considerations

### What This Module Protects

- Redis deployed in private subnets (no internet access)
- TLS encryption for all connections
- AUTH token required for authentication
- Security group limits access to ECS tasks only
- Encryption at rest using AWS-managed keys

### What You Must Configure

- Rotate auth token periodically (every 90 days)
- Monitor failed authentication attempts
- Review security group rules regularly
- Enable AWS Config rules for compliance

## Dependencies

**Required Inputs:**

- VPC ID (from networking module)
- Private subnet IDs (from networking module)
- ECS security group ID (from networking module)
- Authentication token (generate securely)

**AWS Services Used:**

- Amazon ElastiCache (Redis)
- AWS Systems Manager (Parameter Store)
- Amazon CloudWatch (Logs and Metrics)
- AWS KMS (Encryption)

## Related Modules

- **networking**: Provides VPC, subnets, security groups
- **compute**: ECS tasks connect to Redis
- **monitoring**: CloudWatch alarms for Redis metrics

## References

- [ElastiCache Redis Documentation](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/)
- [Celery Redis Backend](https://docs.celeryproject.org/en/stable/getting-started/backends-and-brokers/redis.html)
- [Redis 7.1 Release Notes](https://raw.githubusercontent.com/redis/redis/7.0/00-RELEASENOTES)
