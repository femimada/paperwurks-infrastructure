variable "aws_region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "eu-west-2" # London
}

variable "project_name" {
  description = "Name prefix for all infrastructure resources"
  type        = string
  default     = "paperwurks"
}

variable "environment" {
  type        = string
  description = "The environment name: dev, staging, prod, shared"
  default     = "shared" # Change this default as needed
}