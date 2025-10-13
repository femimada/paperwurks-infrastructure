# -----------------------------------------------------------------------------
# Secrets Manager Outputs
# -----------------------------------------------------------------------------

output "django_secret_arn" {
  description = "ARN of the Django secrets in Secrets Manager"
  value       = aws_secretsmanager_secret.django_config.arn
}

output "django_secret_name" {
  description = "Name of the Django secrets"
  value       = aws_secretsmanager_secret.django_config.name
}

output "external_apis_secret_arn" {
  description = "ARN of the external APIs secrets"
  value       = aws_secretsmanager_secret.external_apis.arn
}

output "external_apis_secret_name" {
  description = "Name of the external APIs secrets"
  value       = aws_secretsmanager_secret.external_apis.name
}

# -----------------------------------------------------------------------------
# Parameter Store Outputs (for reference)
# -----------------------------------------------------------------------------

output "django_environment_parameter" {
  description = "SSM parameter name for ENVIRONMENT"
  value       = aws_ssm_parameter.environment.name
}

output "django_debug_parameter" {
  description = "SSM parameter name for DEBUG"
  value       = aws_ssm_parameter.debug.name
}

output "allowed_hosts_parameter" {
  description = "SSM parameter name for ALLOWED_HOSTS"
  value       = aws_ssm_parameter.allowed_hosts.name
}

output "cors_origins_parameter" {
  description = "SSM parameter name for CORS_ALLOWED_ORIGINS"
  value       = aws_ssm_parameter.cors_origins.name
}

output "log_level_parameter" {
  description = "SSM parameter name for LOG_LEVEL"
  value       = aws_ssm_parameter.log_level.name
}

output "django_settings_module_parameter" {
  description = "SSM parameter name for DJANGO_SETTINGS_MODULE"
  value       = aws_ssm_parameter.django_settings_module.name
}

output "storage_bucket_parameter" {
  description = "SSM parameter name for AWS_STORAGE_BUCKET_NAME"
  value       = aws_ssm_parameter.storage_bucket.name
}

output "aws_region_parameter" {
  description = "SSM parameter name for AWS_REGION"
  value       = aws_ssm_parameter.aws_region.name
}

# -----------------------------------------------------------------------------
# Feature Flag Outputs
# -----------------------------------------------------------------------------

output "enable_ai_analysis_parameter" {
  description = "SSM parameter name for ENABLE_AI_ANALYSIS"
  value       = aws_ssm_parameter.enable_ai_analysis.name
}

output "enable_document_processing_parameter" {
  description = "SSM parameter name for ENABLE_DOCUMENT_PROCESSING"
  value       = aws_ssm_parameter.enable_document_processing.name
}

output "enable_search_integration_parameter" {
  description = "SSM parameter name for ENABLE_SEARCH_INTEGRATION"
  value       = aws_ssm_parameter.enable_search_integration.name
}

# -----------------------------------------------------------------------------
# Production Security Settings Outputs
# -----------------------------------------------------------------------------

output "csrf_origins_parameter" {
  description = "SSM parameter name for CSRF_TRUSTED_ORIGINS (prod only)"
  value       = var.environment == "prod" ? aws_ssm_parameter.csrf_origins[0].name : ""
}

output "secure_ssl_redirect_parameter" {
  description = "SSM parameter name for SECURE_SSL_REDIRECT (prod only)"
  value       = var.environment == "prod" ? aws_ssm_parameter.secure_ssl_redirect[0].name : ""
}

output "session_cookie_secure_parameter" {
  description = "SSM parameter name for SESSION_COOKIE_SECURE (prod only)"
  value       = var.environment == "prod" ? aws_ssm_parameter.session_cookie_secure[0].name : ""
}

output "csrf_cookie_secure_parameter" {
  description = "SSM parameter name for CSRF_COOKIE_SECURE (prod only)"
  value       = var.environment == "prod" ? aws_ssm_parameter.csrf_cookie_secure[0].name : ""
}

output "hsts_seconds_parameter" {
  description = "SSM parameter name for SECURE_HSTS_SECONDS (prod only)"
  value       = var.environment == "prod" ? aws_ssm_parameter.hsts_seconds[0].name : ""
}