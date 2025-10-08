

output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}

output "rds_endpoint" {
  description = "Connection endpoint for the RDS instance"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "rds_address" {
  description = "Hostname of the RDS instance"
  value       = aws_db_instance.main.address
  sensitive   = true
}

output "rds_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.main.port
}

output "database_name" {
  description = "Name of the default database"
  value       = aws_db_instance.main.db_name
}

output "database_username" {
  description = "Master username for the database"
  value       = var.db_username
  sensitive   = true
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "secret_name" {
  description = "Name of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.db_credentials.name
}


output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "db_subnet_group_arn" {
  description = "ARN of the DB subnet group"
  value       = aws_db_subnet_group.main.arn
}



output "db_parameter_group_name" {
  description = "Name of the DB parameter group"
  value       = aws_db_parameter_group.main.name
}

output "db_parameter_group_arn" {
  description = "ARN of the DB parameter group"
  value       = aws_db_parameter_group.main.arn
}



# output "cloudwatch_log_group_name" {
#   description = "Name of the CloudWatch log group for RDS logs"
#   value       = aws_cloudwatch_log_group.postgresql.name
# }

output "monitoring_role_arn" {
  description = "ARN of the enhanced monitoring IAM role"
  value       = var.environment == "prod" ? aws_iam_role.rds_monitoring[0].arn : null
}



output "cpu_alarm_arn" {
  description = "ARN of the CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.database_cpu.arn
}

output "storage_alarm_arn" {
  description = "ARN of the storage space alarm"
  value       = aws_cloudwatch_metric_alarm.database_storage.arn
}

output "memory_alarm_arn" {
  description = "ARN of the memory alarm"
  value       = aws_cloudwatch_metric_alarm.database_memory.arn
}

output "connections_alarm_arn" {
  description = "ARN of the database connections alarm"
  value       = aws_cloudwatch_metric_alarm.database_connections.arn
}


output "connection_string" {
  description = "PostgreSQL connection string (without password)"
  value       = "postgresql://${var.db_username}@${aws_db_instance.main.address}:${aws_db_instance.main.port}/${var.db_name}"
  sensitive   = true
}