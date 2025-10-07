# ECS Cluster Outputs
output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

# ECS Service Outputs
output "ecs_service_arn_backend" {
  description = "ARN of the backend ECS service"
  value       = aws_ecs_service.backend.id
}

output "ecs_service_arn_worker" {
  description = "ARN of the worker ECS service"
  value       = aws_ecs_service.worker.id
}

output "ecs_service_backend_name" {
  description = "Name of the backend ECS service"
  value       = aws_ecs_service.backend.name
}

output "ecs_service_worker_name" {
  description = "Name of the worker ECS service"
  value       = aws_ecs_service.worker.name
}

# Task Definition Outputs
output "task_definition_family_backend" {
  description = "Family name of the backend task definition"
  value       = aws_ecs_task_definition.backend.family
}

output "task_definition_family_worker" {
  description = "Family name of the worker task definition"
  value       = aws_ecs_task_definition.worker.family
}

# IAM Role Outputs
output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task.arn
}

# Load Balancer Outputs
output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_target_group_arn" {
  description = "ARN of the backend target group"
  value       = aws_lb_target_group.backend.arn
}

# Log Group Outputs
output "backend_log_group_name" {
  description = "Name of the backend CloudWatch log group"
  value       = aws_cloudwatch_log_group.backend.name
}

output "worker_log_group_name" {
  description = "Name of the worker CloudWatch log group"
  value       = aws_cloudwatch_log_group.worker.name
}

