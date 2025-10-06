# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "paperwurks"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
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
  description = "Team responsible for resources"
  type        = string
  default     = "platform"
}

# Networking Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16" # Different from dev (10.0.0.0/16)
}

variable "availability_zones" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

# Compute Configuration
variable "ecs_instance_type" {
  description = "Instance type for ECS cluster"
  type        = string
  default     = "t3.medium"
}

variable "ecs_min_size" {
  description = "Minimum number of ECS instances"
  type        = number
  default     = 1
}

variable "ecs_max_size" {
  description = "Maximum number of ECS instances"
  type        = number
  default     = 3
}

variable "ecs_desired_capacity" {
  description = "Desired number of ECS instances"
  type        = number
  default     = 1
}

# Database Configuration
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.small"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "paperwurks"
}

variable "db_username" {
  description = "Master username for database"
  type        = string
  default     = "paperwurks_admin"
  sensitive   = true
}

# Storage Configuration
variable "s3_lifecycle_rules" {
  description = "Lifecycle rules for S3 buckets"
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
      id      = "archive-old-documents"
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

# Monitoring Configuration
variable "alert_email" {
  description = "Email for alerts"
  type        = string
  default     = "devops@paperwurks.com"
}

variable "slack_webhook_url" {
  description = "Slack webhook for notifications"
  type        = string
  default     = ""
  sensitive   = true
}