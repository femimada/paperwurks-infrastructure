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

# Redis Configuration
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