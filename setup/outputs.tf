# Outputs for backend configuration
output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "Name of the S3 bucket for Terraform state"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_state_lock.id
  description = "Name of the DynamoDB table for state locking"
}

output "region" {
  value       = var.aws_region
  description = "AWS region for backend resources"
}

output "backend_config" {
  value = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.id}"
        key            = "ENVIRONMENT/terraform.tfstate"
        region         = "${var.aws_region}"
        dynamodb_table = "${aws_dynamodb_table.terraform_state_lock.id}"
        encrypt        = true
      }
    }
  EOT
  description = "Backend configuration to use in environment files"
}