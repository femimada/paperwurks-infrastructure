variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Redis will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Redis deployment"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID of ECS tasks that need Redis access"
  type        = string
}

variable "cluster_mode_enabled" {
  description = "Enable cluster mode for Redis (recommended for production)"
  type        = bool
  default     = false
}

variable "auth_token" {
  description = "Authentication token for Redis (must be 16-128 characters)"
  type        = string
  sensitive   = true
}

variable "maintenance_window" {
  description = "Maintenance window for ElastiCache (UTC)"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "snapshot_window" {
  description = "Daily snapshot window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "snapshot_retention_limit" {
  description = "Number of days to retain snapshots"
  type        = number
  default     = 7
}