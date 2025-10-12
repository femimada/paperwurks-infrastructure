# ElastiCache Replication Group Outputs
output "replication_group_id" {
  description = "ID of the ElastiCache replication group"
  value       = aws_elasticache_replication_group.redis.id
}

output "replication_group_arn" {
  description = "ARN of the ElastiCache replication group"
  value       = aws_elasticache_replication_group.redis.arn
}

output "primary_endpoint_address" {
  description = "Primary endpoint address for Redis"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "configuration_endpoint_address" {
  description = "Configuration endpoint address (cluster mode enabled)"
  value       = aws_elasticache_replication_group.redis.configuration_endpoint_address
}

output "reader_endpoint_address" {
  description = "Reader endpoint address for read replicas"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

output "redis_port" {
  description = "Redis port number"
  value       = aws_elasticache_replication_group.redis.port
}

output "redis_security_group_id" {
  description = "Security group ID for Redis cluster"
  value       = aws_security_group.redis.id
}

# SSM Parameter Outputs
output "redis_endpoint_parameter_name" {
  description = "SSM parameter name for Redis endpoint"
  value       = aws_ssm_parameter.redis_endpoint.name
}

output "redis_port_parameter_name" {
  description = "SSM parameter name for Redis port"
  value       = aws_ssm_parameter.redis_port.name
}

output "redis_url_parameter_name" {
  description = "SSM parameter name for complete Redis URL"
  value       = aws_ssm_parameter.redis_url.name
}

output "redis_auth_token_parameter_name" {
  description = "SSM parameter name for Redis auth token"
  value       = aws_ssm_parameter.redis_auth_token.name
  sensitive   = true
}

# CloudWatch Log Groups
output "slow_log_group_name" {
  description = "CloudWatch log group name for Redis slow logs"
  value       = aws_cloudwatch_log_group.redis_slow_log.name
}

output "engine_log_group_name" {
  description = "CloudWatch log group name for Redis engine logs"
  value       = aws_cloudwatch_log_group.redis_engine_log.name
}