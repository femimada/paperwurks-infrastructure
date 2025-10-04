variable "aws_region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "eu-west-2" # London
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "paperwurks"
}