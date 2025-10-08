

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


# resource "aws_cloudwatch_log_group" "postgresql" {
#   name              = "/aws/rds/instance/${var.project_name}-${var.environment}-db/postgresql"
#   retention_in_days = var.environment == "prod" ? 30 : 7

#   tags = {
#     Name        = "${var.project_name}-${var.environment}-rds-logs"
#     Environment = var.environment
#   }
#   lifecycle {
#     ignore_changes = [name]
#   }
# }

resource "aws_iam_role" "rds_monitoring" {
  count = var.environment == "prod" ? 1 : 0

  name = "${var.project_name}-${var.environment}-rds-monitoring"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-monitoring"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count      = var.environment == "prod" ? 1 : 0
  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}