# -----------------------------------------------------------------------------
# RDS Database Instance
# -----------------------------------------------------------------------------

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-db"

  # Engine Configuration
  engine                = "postgres"
  engine_version        = var.engine_version
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  # Database Credentials
  db_name  = var.db_name
  username = var.db_username
  password = random_password.master.result
  port     = 5432

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  # Backup & Maintenance
  backup_retention_period   = var.backup_retention
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  copy_tags_to_snapshot     = true

  # Groups & Logging
  parameter_group_name            = aws_db_parameter_group.main.name
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # Performance & Monitoring
  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.enable_performance_insights ? 7 : null
  monitoring_interval                   = var.environment == "prod" ? 60 : 0
  monitoring_role_arn                   = var.environment == "prod" ? aws_iam_role.rds_monitoring[0].arn : null

  # Management Settings
  auto_minor_version_upgrade = var.environment != "prod"
  deletion_protection        = var.deletion_protection
  apply_immediately          = var.environment != "prod"

  tags = {
    Name        = "${var.project_name}-${var.environment}-db"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [
      password,
      final_snapshot_identifier,

    ]
  }
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.project_name}-${var.environment}-postgres15-params"
  family = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }
  parameter {
    name  = "log_disconnections"
    value = "1"
  }
  parameter {
    name  = "log_duration"
    value = "1"
  }
  parameter {
    name  = "log_statement"
    value = var.environment == "prod" ? "ddl" : "all"
  }
  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres15-params"
    Environment = var.environment
  }
}

