# -----------------------------------------------------------------------------
# Environment Configuration
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "paperwurks"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "engineering"
}

variable "team" {
  description = "Team responsible"
  type        = string
  default     = "platform"
}

# -----------------------------------------------------------------------------
# Alert Configuration
# -----------------------------------------------------------------------------

variable "alert_email" {
  description = "Email for alerts"
  type        = string
  default     = "devops@paperwurks.com"
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  default     = ""
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Networking Configuration
# -----------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

# -----------------------------------------------------------------------------
# Fargate Configuration
# -----------------------------------------------------------------------------

variable "backend_cpu" {
  description = "CPU units for backend Fargate task"
  type        = number
  default     = 1024  # 1 vCPU for production
}

variable "backend_memory" {
  description = "Memory for backend Fargate task in MB"
  type        = number
  default     = 2048  # 2 GB for production
}

variable "worker_cpu" {
  description = "CPU units for worker Fargate task"
  type        = number
  default     = 512  # 0.5 vCPU for production workers
}

variable "worker_memory" {
  description = "Memory for worker Fargate task in MB"
  type        = number
  default     = 1024  # 1 GB for production workers
}

variable "backend_desired_count" {
  description = "Desired number of backend tasks"
  type        = number
  default     = 2  # Minimum 2 for HA
}

variable "worker_desired_count" {
  description = "Desired number of worker tasks"
  type        = number
  default     = 2  # 2 workers for production
}

variable "backend_image" {
  description = "Backend container image"
  type        = string
  default     = "nginx:latest" # Placeholder - will be updated by CI/CD
}

variable "worker_image" {
  description = "Worker container image"
  type        = string
  default     = "nginx:latest" # Placeholder - will be updated by CI/CD
}

# -----------------------------------------------------------------------------
# Database Configuration
# -----------------------------------------------------------------------------

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"  # Larger for production
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 100  # 100 GB for production
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "paperwurks_prod"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "paperwurks_admin"
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Storage Configuration
# -----------------------------------------------------------------------------

variable "enable_versioning" {
  description = "Enable S3 versioning"
  type        = bool
  default     = true  # Always enabled in production
}

variable "s3_lifecycle_rules" {
  description = "S3 lifecycle rules"
  type = list(object({
    id      = string
    enabled = bool
    transitions = list(object({
      days          = number
      storage_class = string
    }))
  }))
  default = [
    {
      id      = "transition-to-ia"
      enabled = true
      transitions = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        },
        {
          days          = 365
          storage_class = "GLACIER"
        }
      ]
    }
  ]
}

