variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
  default     = []
}

variable "alb_sg_id" {
  description = "Security group ID for Application Load Balancer"
  type        = string
}

variable "ecs_sg_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "backend_image" {
  description = "Docker image for backend service"
  type        = string
  default     = "nginx:latest"
}

variable "worker_image" {
  description = "Docker image for worker service"
  type        = string
  default     = "nginx:latest"
}

variable "backend_cpu" {
  description = "CPU units for backend task (1024 = 1 vCPU)"
  type        = number
  default     = 512
}

variable "backend_memory" {
  description = "Memory for backend task in MB"
  type        = number
  default     = 1024
}

variable "worker_cpu" {
  description = "CPU units for worker task"
  type        = number
  default     = 256
}

variable "worker_memory" {
  description = "Memory for worker task in MB"
  type        = number
  default     = 512
}

variable "backend_desired_count" {
  description = "Desired number of backend tasks"
  type        = number
  default     = 2
}

variable "worker_desired_count" {
  description = "Desired number of worker tasks"
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# Redis Configuration (from ElastiCache module)
# -----------------------------------------------------------------------------

variable "redis_url_parameter_name" {
  description = "SSM Parameter name for Redis URL (for Celery)"
  type        = string
  default     = ""
}

variable "redis_endpoint_parameter_name" {
  description = "SSM Parameter name for Redis endpoint"
  type        = string
  default     = ""
}

variable "redis_port_parameter_name" {
  description = "SSM Parameter name for Redis port"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Django Configuration (from app_config module)
# -----------------------------------------------------------------------------

variable "django_secret_arn" {
  description = "ARN of Django secrets in Secrets Manager"
  type        = string
  default     = ""
}

variable "django_debug_parameter" {
  description = "SSM Parameter name for DEBUG setting"
  type        = string
  default     = ""
}

variable "allowed_hosts_parameter" {
  description = "SSM Parameter name for ALLOWED_HOSTS"
  type        = string
  default     = ""
}

variable "cors_origins_parameter" {
  description = "SSM Parameter name for CORS_ALLOWED_ORIGINS"
  type        = string
  default     = ""
}

variable "log_level_parameter" {
  description = "SSM Parameter name for LOG_LEVEL"
  type        = string
  default     = ""
}

variable "django_settings_module_parameter" {
  description = "SSM Parameter name for DJANGO_SETTINGS_MODULE"
  type        = string
  default     = ""
}

variable "storage_bucket_parameter" {
  description = "SSM Parameter name for AWS_STORAGE_BUCKET_NAME"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Feature Flags (from app_config module)
# -----------------------------------------------------------------------------

variable "enable_ai_analysis_parameter" {
  description = "SSM Parameter name for ENABLE_AI_ANALYSIS"
  type        = string
  default     = ""
}

variable "enable_document_processing_parameter" {
  description = "SSM Parameter name for ENABLE_DOCUMENT_PROCESSING"
  type        = string
  default     = ""
}

variable "enable_search_integration_parameter" {
  description = "SSM Parameter name for ENABLE_SEARCH_INTEGRATION"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Production Security Settings (from app_config module)
# -----------------------------------------------------------------------------

variable "csrf_origins_parameter" {
  description = "SSM Parameter name for CSRF_TRUSTED_ORIGINS (prod only)"
  type        = string
  default     = ""
}

variable "secure_ssl_redirect_parameter" {
  description = "SSM Parameter name for SECURE_SSL_REDIRECT (prod only)"
  type        = string
  default     = ""
}

variable "session_cookie_secure_parameter" {
  description = "SSM Parameter name for SESSION_COOKIE_SECURE (prod only)"
  type        = string
  default     = ""
}

variable "csrf_cookie_secure_parameter" {
  description = "SSM Parameter name for CSRF_COOKIE_SECURE (prod only)"
  type        = string
  default     = ""
}

variable "hsts_seconds_parameter" {
  description = "SSM Parameter name for SECURE_HSTS_SECONDS (prod only)"
  type        = string
  default     = ""
}