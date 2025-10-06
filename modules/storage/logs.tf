
resource "aws_s3_bucket" "logs" {
  count         = var.enable_access_logging ? 1 : 0
  bucket        = "${var.project_name}-${var.environment}-logs"
  force_destroy = var.force_destroy

  tags = {
    Name        = "${var.project_name}-${var.environment}-logs"
    Environment = var.environment
    Purpose     = "Access Logs"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  count  = var.enable_access_logging ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  count  = var.enable_access_logging ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Auto-delete logs after 90 days
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  count  = var.enable_access_logging ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    expiration {
      days = 90
    }
    filter {
      prefix = ""
    }
  }
}

# Enable logging on documents bucket
resource "aws_s3_bucket_logging" "documents" {
  count  = var.enable_access_logging ? 1 : 0
  bucket = aws_s3_bucket.documents.id

  target_bucket = aws_s3_bucket.logs[0].id
  target_prefix = "documents/"
}

# Enable logging on uploads bucket
resource "aws_s3_bucket_logging" "uploads" {
  count  = var.enable_access_logging ? 1 : 0
  bucket = aws_s3_bucket.uploads.id

  target_bucket = aws_s3_bucket.logs[0].id
  target_prefix = "uploads/"
}