

output "ecs_cluster_name" {
  value       = module.compute.ecs_cluster_name
  description = "Name of the ECS cluster for deployments"
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