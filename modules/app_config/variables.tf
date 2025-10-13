variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "documents_bucket_name" {
  description = "S3 documents bucket name from storage module"
  type        = string
}

variable "enable_ai_analysis" {
  description = "Enable AI analysis features"
  type        = bool
  default     = true
}

variable "enable_document_processing" {
  description = "Enable document processing"
  type        = bool
  default     = true
}

variable "enable_search_integration" {
  description = "Enable search integration"
  type        = bool
  default     = true
}

variable "nlis_api_key" {
  description = "NLIS API key (optional)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "groundsure_api_key" {
  description = "Groundsure API key (optional)"
  type        = string
  default     = ""
  sensitive   = true
}