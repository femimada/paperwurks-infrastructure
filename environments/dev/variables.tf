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
  default     = "dev"
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

# -----------------------------------------------------------------------------
# Networking Configuration
# -----------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
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
  default     = 512
}

variable "backend_memory" {
  description = "Memory for backend Fargate task in MB"
  type        = number
  default     = 1024
}

variable "worker_cpu" {
  description = "CPU units for worker Fargate task"
  type        = number
  default     = 256
}

variable "worker_memory" {
  description = "Memory for worker Fargate task in MB"
  type        = number
  default     = 512
}

variable "backend_desired_count" {
  description = "Desired number of backend tasks"
  type        = number
  default     = 1
}

variable "worker_desired_count" {
  description = "Desired number of worker tasks"
  type        = number
  default     = 1
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
  default     = "db.t3.small"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "paperwurks_dev"
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
  default     = false
}