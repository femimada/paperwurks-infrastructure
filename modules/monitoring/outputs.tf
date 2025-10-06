# SNS Topic Outputs
output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.alerts.name
}

# Log Group Outputs
output "application_log_group_name" {
  description = "Name of the application log group"
  value       = aws_cloudwatch_log_group.application.name
}

output "application_log_group_arn" {
  description = "ARN of the application log group"
  value       = aws_cloudwatch_log_group.application.arn
}

output "infrastructure_log_group_name" {
  description = "Name of the infrastructure log group"
  value       = aws_cloudwatch_log_group.infrastructure.name
}

output "infrastructure_log_group_arn" {
  description = "ARN of the infrastructure log group"
  value       = aws_cloudwatch_log_group.infrastructure.arn
}

# Dashboard Outputs
output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "dashboard_url" {
  description = "URL to the CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

# Alarm Outputs
output "error_rate_alarm_arn" {
  description = "ARN of the error rate alarm"
  value       = aws_cloudwatch_metric_alarm.high_error_rate.arn
}

output "alb_5xx_alarm_arn" {
  description = "ARN of the ALB 5XX alarm"
  value       = aws_cloudwatch_metric_alarm.alb_5xx_errors.arn
}

output "unhealthy_hosts_alarm_arn" {
  description = "ARN of the unhealthy hosts alarm"
  value       = aws_cloudwatch_metric_alarm.unhealthy_hosts.arn
}

# Lambda Outputs (if Slack enabled)
output "slack_lambda_arn" {
  description = "ARN of the Slack notifier Lambda function"
  value       = var.slack_webhook_url != "" ? aws_lambda_function.slack_notifier[0].arn : null
}

output "slack_lambda_name" {
  description = "Name of the Slack notifier Lambda function"
  value       = var.slack_webhook_url != "" ? aws_lambda_function.slack_notifier[0].function_name : null
}