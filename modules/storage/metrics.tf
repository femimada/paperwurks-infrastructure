
resource "aws_s3_bucket_metric" "documents_all" {
  bucket = aws_s3_bucket.documents.id
  name   = "EntireBucket"
}

resource "aws_s3_bucket_metric" "uploads_all" {
  bucket = aws_s3_bucket.uploads.id
  name   = "EntireBucket"
}