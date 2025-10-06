# -----------------------------------------------------------------------------
# CloudWatch Log Groups
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "application" {
  name              = "/application/${var.project_name}/${var.environment}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-${var.environment}-app-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "infrastructure" {
  name              = "/infrastructure/${var.project_name}/${var.environment}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.project_name}-${var.environment}-infra-logs"
    Environment = var.environment
  }
}



resource "aws_cloudwatch_log_metric_filter" "error_count" {
  name           = "${var.project_name}-${var.environment}-error-count"
  log_group_name = aws_cloudwatch_log_group.application.name
  pattern        = "[time, request_id, level = ERROR*, ...]"

  metric_transformation {
    name          = "ErrorCount"
    namespace     = "${var.project_name}/${var.environment}"
    value         = "1"
    default_value = 0
  }
}

resource "aws_cloudwatch_log_metric_filter" "response_time" {
  name           = "${var.project_name}-${var.environment}-response-time"
  log_group_name = aws_cloudwatch_log_group.application.name
  pattern        = "[time, request_id, level, method, path, status, duration]"

  metric_transformation {
    name      = "ResponseTime"
    namespace = "${var.project_name}/${var.environment}"
    value     = "$duration"
    unit      = "Milliseconds"
  }
}