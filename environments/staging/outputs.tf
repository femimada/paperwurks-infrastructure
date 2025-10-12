# Network Outputs
output "vpc_id" {
  value       = module.networking.vpc_id
  description = "VPC ID"
}

output "private_subnet_ids" {
  value       = module.networking.private_subnet_ids
  description = "Private subnet IDs"
}

# ECS Outputs
output "ecs_cluster_name" {
  value       = module.compute.ecs_cluster_name
  description = "Name of the ECS cluster for deployments"
}

output "ecs_cluster_arn" {
  value       = module.compute.ecs_cluster_arn
  description = "ARN of the ECS cluster"
}

output "ecs_service_backend_name" {
  value       = module.compute.ecs_service_backend_name
  description = "Name of the backend ECS service"
}

output "ecs_service_worker_name" {
  value       = module.compute.ecs_service_worker_name
  description = "Name of the worker ECS service"
}

output "task_definition_family_backend" {
  value       = module.compute.task_definition_family_backend
  description = "Task definition family name for backend"
}

# Database Outputs
output "rds_endpoint" {
  value       = module.database.rds_endpoint
  description = "RDS endpoint"
  sensitive   = true
}

output "rds_database_name" {
  value       = module.database.database_name
  description = "RDS database name"
}

# Storage Outputs
output "s3_documents_bucket" {
  value       = module.storage.documents_bucket_name
  description = "S3 bucket for documents"
}

# Load Balancer Outputs
output "alb_dns_name" {
  value       = module.compute.alb_dns_name
  description = "DNS name of the Application Load Balancer"
}

output "alb_zone_id" {
  value       = module.compute.alb_zone_id
  description = "Zone ID of the Application Load Balancer"
}

# Storage Outputs
output "documents_bucket_name" {
  description = "Name of the documents S3 bucket"
  value       = module.storage.documents_bucket_name
}

output "documents_bucket_arn" {
  description = "ARN of the documents S3 bucket"
  value       = module.storage.documents_bucket_arn
}

output "uploads_bucket_name" {
  description = "Name of the uploads S3 bucket"
  value       = module.storage.uploads_bucket_name
}

output "uploads_bucket_arn" {
  description = "ARN of the uploads S3 bucket"
  value       = module.storage.uploads_bucket_arn
}

# Monitoring Outputs
output "sns_alerts_topic_arn" {
  description = "ARN of the SNS alerts topic"
  value       = module.monitoring.sns_topic_arn
}

output "dashboard_url" {
  description = "URL to CloudWatch dashboard"
  value       = module.monitoring.dashboard_url
}

output "application_log_group" {
  description = "Name of the application log group"
  value       = module.monitoring.application_log_group_name
}


output "redis_endpoint" {
  description = "Redis primary endpoint address"
  value       = module.elasticache.primary_endpoint_address
  sensitive   = true
}

output "redis_port" {
  description = "Redis port"
  value       = module.elasticache.redis_port
}

output "redis_url_parameter" {
  description = "SSM Parameter Store name for Redis URL"
  value       = module.elasticache.redis_url_parameter_name
}

output "redis_endpoint_parameter" {
  description = "SSM Parameter Store name for Redis endpoint"
  value       = module.elasticache.redis_endpoint_parameter_name
}

output "redis_security_group_id" {
  description = "Security group ID for Redis cluster"
  value       = module.elasticache.redis_security_group_id
}