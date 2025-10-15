# -----------------------------------------------------------------------------
# Application Configuration Module
# Manages Django application secrets and configuration parameters
# -----------------------------------------------------------------------------

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# Fetch Existing Database Credentials
# -----------------------------------------------------------------------------

data "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.project_name}/${var.environment}/database/master-credentials"
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}

# -----------------------------------------------------------------------------
# Local Variables
# -----------------------------------------------------------------------------

locals {
  # Parse database credentials
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)

  # Construct DATABASE_URL with SSL and connection settings
  database_url = "postgresql://${local.db_creds.username}:${local.db_creds.password}@${local.db_creds.host}:${local.db_creds.port}/${local.db_creds.dbname}?sslmode=require&connect_timeout=10"

  # Environment-specific ALLOWED_HOSTS
  allowed_hosts = {
      dev     = "localhost,127.0.0.1,10.0.0.0/16,*.elb.amazonaws.com"
      staging = "10.0.0.0/16,*.elb.amazonaws.com,staging.paperwurks.co.uk"
      prod    = "10.0.0.0/16,*.elb.amazonaws.com,api.paperwurks.co.uk,paperwurks.co.uk"
  }

  # Environment-specific CORS origins
  cors_origins = {
    dev     = "http://localhost:3000,http://localhost:5173"
    staging = "https://staging.paperwurks.co.uk,https://app-staging.paperwurks.co.uk"
    prod    = "https://paperwurks.co.uk,https://app.paperwurks.co.uk"
  }

  # Environment-specific CSRF trusted origins (production only)
  csrf_origins = {
    dev     = ""
    staging = ""
    prod    = "https://paperwurks.co.uk,https://app.paperwurks.co.uk,https://api.paperwurks.co.uk"
  }

  # Log levels per environment
  log_levels = {
    dev     = "DEBUG"
    staging = "INFO"
    prod    = "INFO"
  }
}

# -----------------------------------------------------------------------------
# Django Secret Key Generation
# -----------------------------------------------------------------------------

resource "random_password" "django_secret_key" {
  length           = 50
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}|;:,.<>?"
}

# -----------------------------------------------------------------------------
# Secrets Manager - Django Configuration (Sensitive)
# -----------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "django_config" {
  name                    = "${var.project_name}/${var.environment}/django"
  description             = "Django application secrets for ${var.environment}"
  recovery_window_in_days = var.environment == "prod" ? 30 : 0

  tags = {
    Name        = "${var.project_name}-${var.environment}-django-secrets"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "django_config" {
  secret_id = aws_secretsmanager_secret.django_config.id

  secret_string = jsonencode({
    SECRET_KEY   = random_password.django_secret_key.result
    DATABASE_URL = local.database_url
  })
}

# -----------------------------------------------------------------------------
# Secrets Manager - External APIs (Sensitive - Placeholders)
# -----------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "external_apis" {
  name                    = "${var.project_name}/${var.environment}/external_apis"
  description             = "External API keys and credentials for ${var.environment}"
  recovery_window_in_days = var.environment == "prod" ? 30 : 0

  tags = {
    Name        = "${var.project_name}-${var.environment}-external-apis"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "external_apis" {
  secret_id = aws_secretsmanager_secret.external_apis.id

  secret_string = jsonencode({
    NLIS_API_KEY       = var.nlis_api_key != "" ? var.nlis_api_key : ""
    GROUNDSURE_API_KEY = var.groundsure_api_key != "" ? var.groundsure_api_key : ""
  })
}

# -----------------------------------------------------------------------------
# Parameter Store - Django Non-Sensitive Configuration
# -----------------------------------------------------------------------------

resource "aws_ssm_parameter" "environment" {
  name        = "/${var.project_name}/${var.environment}/django/ENVIRONMENT"
  description = "Django environment name"
  type        = "String"
  value       = var.environment

  tags = {
    Name        = "${var.project_name}-${var.environment}-django-environment"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ssm_parameter" "debug" {
  name        = "/${var.project_name}/${var.environment}/django/DEBUG"
  description = "Django DEBUG setting"
  type        = "String"
  value       = var.environment == "prod" ? "False" : "True"

  tags = {
    Name        = "${var.project_name}-${var.environment}-django-debug"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ssm_parameter" "allowed_hosts" {
  name        = "/${var.project_name}/${var.environment}/django/ALLOWED_HOSTS"
  description = "Django ALLOWED_HOSTS setting"
  type        = "String"
  value       = local.allowed_hosts[var.environment]

  tags = {
    Name        = "${var.project_name}-${var.environment}-django-allowed-hosts"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ssm_parameter" "cors_origins" {
  name        = "/${var.project_name}/${var.environment}/django/CORS_ALLOWED_ORIGINS"
  description = "Django CORS allowed origins"
  type        = "String"
  value       = local.cors_origins[var.environment]

  tags = {
    Name        = "${var.project_name}-${var.environment}-django-cors"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ssm_parameter" "csrf_origins" {
  count       = var.environment == "prod" ? 1 : 0
  name        = "/${var.project_name}/${var.environment}/django/CSRF_TRUSTED_ORIGINS"
  description = "Django CSRF trusted origins"
  type        = "String"
  value       = local.csrf_origins[var.environment]

  tags = {
    Name        = "${var.project_name}-${var.environment}-django-csrf-origins"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ssm_parameter" "log_level" {
  name        = "/${var.project_name}/${var.environment}/django/LOG_LEVEL"
  description = "Application log level"
  type        = "String"
  value       = local.log_levels[var.environment]

  tags = {
    Name        = "${var.project_name}-${var.environment}-django-log-level"
    Environment = var.environment
    Project     = var.project_name
  }
}


resource "aws_ssm_parameter" "django_settings_module" {
  name        = "/${var.project_name}/${var.environment}/django/DJANGO_SETTINGS_MODULE"
  description = "Django settings module path"
  type        = "String"
  
  value = lookup(
    {
      "prod"    = "apps.config.settings.production",
      "staging" = "apps.config.settings.staging",
      "dev"     = "apps.config.settings.development"
    },
    var.environment,
    "apps.config.settings.development" 
  )
    tags = {
    Name        = "${var.project_name}-${var.environment}-django-settings-module"
    Environment = var.environment
    Project     = var.project_name
  }
}



# -----------------------------------------------------------------------------
# Parameter Store - AWS Configuration
# -----------------------------------------------------------------------------

resource "aws_ssm_parameter" "aws_region" {
  name        = "/${var.project_name}/${var.environment}/aws/REGION"
  description = "AWS region"
  type        = "String"
  value       = data.aws_region.current.name

  tags = {
    Name        = "${var.project_name}-${var.environment}-aws-region"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ssm_parameter" "storage_bucket" {
  name        = "/${var.project_name}/${var.environment}/aws/STORAGE_BUCKET_NAME"
  description = "S3 storage bucket name"
  type        = "String"
  value       = var.documents_bucket_name

  tags = {
    Name        = "${var.project_name}-${var.environment}-storage-bucket"
    Environment = var.environment
    Project     = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Parameter Store - Feature Flags
# -----------------------------------------------------------------------------

resource "aws_ssm_parameter" "enable_ai_analysis" {
  name        = "/${var.project_name}/${var.environment}/features/ENABLE_AI_ANALYSIS"
  description = "Enable AI analysis features"
  type        = "String"
  value       = var.enable_ai_analysis ? "True" : "False"

  tags = {
    Name        = "${var.project_name}-${var.environment}-feature-ai"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ssm_parameter" "enable_document_processing" {
  name        = "/${var.project_name}/${var.environment}/features/ENABLE_DOCUMENT_PROCESSING"
  description = "Enable document processing"
  type        = "String"
  value       = var.enable_document_processing ? "True" : "False"

  tags = {
    Name        = "${var.project_name}-${var.environment}-feature-docs"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ssm_parameter" "enable_search_integration" {
  name        = "/${var.project_name}/${var.environment}/features/ENABLE_SEARCH_INTEGRATION"
  description = "Enable search integration"
  type        = "String"
  value       = var.enable_search_integration ? "True" : "False"

  tags = {
    Name        = "${var.project_name}-${var.environment}-feature-search"
    Environment = var.environment
    Project     = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Parameter Store - Security Settings (Production)
# -----------------------------------------------------------------------------

resource "aws_ssm_parameter" "secure_ssl_redirect" {
  count       = var.environment == "prod" ? 1 : 0
  name        = "/${var.project_name}/${var.environment}/django/SECURE_SSL_REDIRECT"
  description = "Django SECURE_SSL_REDIRECT setting"
  type        = "String"
  value       = "True"

  tags = {
    Name        = "${var.project_name}-${var.environment}-secure-ssl"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ssm_parameter" "session_cookie_secure" {
  count       = var.environment == "prod" ? 1 : 0
  name        = "/${var.project_name}/${var.environment}/django/SESSION_COOKIE_SECURE"
  description = "Django SESSION_COOKIE_SECURE setting"
  type        = "String"
  value       = "True"

  tags = {
    Name        = "${var.project_name}-${var.environment}-session-secure"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ssm_parameter" "csrf_cookie_secure" {
  count       = var.environment == "prod" ? 1 : 0
  name        = "/${var.project_name}/${var.environment}/django/CSRF_COOKIE_SECURE"
  description = "Django CSRF_COOKIE_SECURE setting"
  type        = "String"
  value       = "True"

  tags = {
    Name        = "${var.project_name}-${var.environment}-csrf-secure"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ssm_parameter" "hsts_seconds" {
  count       = var.environment == "prod" ? 1 : 0
  name        = "/${var.project_name}/${var.environment}/django/SECURE_HSTS_SECONDS"
  description = "Django SECURE_HSTS_SECONDS setting"
  type        = "String"
  value       = "31536000"

  tags = {
    Name        = "${var.project_name}-${var.environment}-hsts"
    Environment = var.environment
    Project     = var.project_name
  }
}