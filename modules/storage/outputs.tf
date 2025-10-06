# Documents Bucket Outputs
output "documents_bucket_id" {
  description = "ID of the documents bucket"
  value       = aws_s3_bucket.documents.id
}

output "documents_bucket_arn" {
  description = "ARN of the documents bucket"
  value       = aws_s3_bucket.documents.arn
}

output "documents_bucket_name" {
  description = "Name of the documents bucket"
  value       = aws_s3_bucket.documents.bucket
}

output "documents_bucket_regional_domain_name" {
  description = "Regional domain name of the documents bucket"
  value       = aws_s3_bucket.documents.bucket_regional_domain_name
}

# Uploads Bucket Outputs
output "uploads_bucket_id" {
  description = "ID of the uploads bucket"
  value       = aws_s3_bucket.uploads.id
}

output "uploads_bucket_arn" {
  description = "ARN of the uploads bucket"
  value       = aws_s3_bucket.uploads.arn
}

output "uploads_bucket_name" {
  description = "Name of the uploads bucket"
  value       = aws_s3_bucket.uploads.bucket
}

output "uploads_bucket_regional_domain_name" {
  description = "Regional domain name of the uploads bucket"
  value       = aws_s3_bucket.uploads.bucket_regional_domain_name
}

# Logs Bucket Outputs (if enabled)
output "logs_bucket_id" {
  description = "ID of the logs bucket"
  value       = var.enable_access_logging ? aws_s3_bucket.logs[0].id : null
}

output "logs_bucket_arn" {
  description = "ARN of the logs bucket"
  value       = var.enable_access_logging ? aws_s3_bucket.logs[0].arn : null
}

output "logs_bucket_name" {
  description = "Name of the logs bucket"
  value       = var.enable_access_logging ? aws_s3_bucket.logs[0].bucket : null
}

# Bucket Configuration Outputs
output "versioning_enabled" {
  description = "Whether versioning is enabled on documents bucket"
  value       = var.enable_versioning
}

output "encryption_enabled" {
  description = "Whether encryption is enabled on buckets"
  value       = var.enable_encryption
}