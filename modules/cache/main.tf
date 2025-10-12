# -----------------------------------------------------------------------------
# ElastiCache Redis for Celery Broker
# -----------------------------------------------------------------------------

data "aws_region" "current" {}

locals {
  redis_port         = 6379
  node_type          = var.environment == "prod" ? "cache.t4g.small" : "cache.t4g.micro"
  num_cache_clusters = var.environment == "prod" ? 2 : 1
  automatic_failover = var.environment == "prod" ? true : false
  multi_az_enabled   = var.environment == "prod" ? true : false
}

# -----------------------------------------------------------------------------
# ElastiCache Subnet Group
# -----------------------------------------------------------------------------

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.project_name}-${var.environment}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis-subnet-group"
    Environment = var.environment
    Project     = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Security Group for Redis
# -----------------------------------------------------------------------------

resource "aws_security_group" "redis" {
  name_prefix = "${var.project_name}-${var.environment}-redis-"
  vpc_id      = var.vpc_id
  description = "Security group for ElastiCache Redis - allows ECS task access only"

  ingress {
    from_port       = local.redis_port
    to_port         = local.redis_port
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
    description     = "Redis access from ECS tasks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis-sg"
    Environment = var.environment
    Project     = var.project_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# ElastiCache Parameter Group
# -----------------------------------------------------------------------------

resource "aws_elasticache_parameter_group" "redis" {
  name   = "${var.project_name}-${var.environment}-redis-params"
  family = "redis7"

  description = "Custom parameter group for Redis 7.1 - Celery optimized"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name  = "timeout"
    value = "300"
  }

  parameter {
    name  = "tcp-keepalive"
    value = "300"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis-params"
    Environment = var.environment
    Project     = var.project_name
  }
}

# -----------------------------------------------------------------------------
# ElastiCache Replication Group (Cluster Mode Disabled for Dev/Staging)
# ElastiCache Replication Group (Cluster Mode Enabled for Prod)
# -----------------------------------------------------------------------------

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${var.project_name}-${var.environment}-redis"
  description          = "Redis cluster for Celery broker - ${var.environment}"
  engine               = "redis"
  engine_version       = "7.1"
  node_type            = local.node_type
  port                 = local.redis_port
  parameter_group_name = aws_elasticache_parameter_group.redis.name
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]

  num_cache_clusters         = var.cluster_mode_enabled ? null : local.num_cache_clusters
  automatic_failover_enabled = local.automatic_failover
  multi_az_enabled           = local.multi_az_enabled
  num_node_groups            = var.cluster_mode_enabled ? 1 : null
  replicas_per_node_group    = var.cluster_mode_enabled ? 1 : null
  maintenance_window         = var.maintenance_window
  snapshot_window            = var.snapshot_window
  snapshot_retention_limit   = var.snapshot_retention_limit
  apply_immediately          = var.environment != "prod"
  auto_minor_version_upgrade = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = var.auth_token

  # Logging
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_slow_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis_engine_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Celery Broker"
  }

  lifecycle {
    prevent_destroy = false
  }
}

# -----------------------------------------------------------------------------
# CloudWatch Log Groups
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "redis_slow_log" {
  name              = "/aws/elasticache/${var.project_name}-${var.environment}/redis/slow-log"
  retention_in_days = var.environment == "prod" ? 30 : 7

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis-slow-log"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "redis_engine_log" {
  name              = "/aws/elasticache/${var.project_name}-${var.environment}/redis/engine-log"
  retention_in_days = var.environment == "prod" ? 30 : 7

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis-engine-log"
    Environment = var.environment
    Project     = var.project_name
  }
}

# -----------------------------------------------------------------------------
# SSM Parameter Store - Redis Connection String
# -----------------------------------------------------------------------------

resource "aws_ssm_parameter" "redis_endpoint" {
  name        = "/paperwurks/${var.environment}/redis/endpoint"
  description = "Redis primary endpoint for Celery broker - ${var.environment}"
  type        = "String"
  value       = var.cluster_mode_enabled ? aws_elasticache_replication_group.redis.configuration_endpoint_address : aws_elasticache_replication_group.redis.primary_endpoint_address

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis-endpoint"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ssm_parameter" "redis_port" {
  name        = "/paperwurks/${var.environment}/redis/port"
  description = "Redis port - ${var.environment}"
  type        = "String"
  value       = tostring(local.redis_port)

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis-port"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ssm_parameter" "redis_auth_token" {
  name        = "/paperwurks/${var.environment}/redis/auth-token"
  description = "Redis authentication token - ${var.environment}"
  type        = "SecureString"
  value       = var.auth_token

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis-auth-token"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ssm_parameter" "redis_url" {
  name        = "/paperwurks/${var.environment}/redis/url"
  description = "Complete Redis URL for Celery - ${var.environment}"
  type        = "SecureString"
  value       = "rediss://:${var.auth_token}@${var.cluster_mode_enabled ? aws_elasticache_replication_group.redis.configuration_endpoint_address : aws_elasticache_replication_group.redis.primary_endpoint_address}:${local.redis_port}/0"

  tags = {
    Name        = "${var.project_name}-${var.environment}-redis-url"
    Environment = var.environment
    Project     = var.project_name
  }
}