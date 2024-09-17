# CloudTrail
# - enable CloudTrail
# - S3 bucket to store logs
# - S3 bucket ownership controls 
# - S3 bucket ACL
# - S3 bucket server-side encryption

# Enable CloudTrail
resource "aws_cloudtrail" "tf_cloudtrail" {
  name                          = "tf-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.tf_cloudtrail_bucket.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::my-bucket/"]
    }
  }

  cloud_watch_logs_group_arn = aws_cloudwatch_log_group.app_log_group.arn
  cloud_watch_logs_role_arn  = aws_iam_role.cloudwatch_role.arn

  tags = {
    Name = "my-cloudtrail"
  }
}

# S3 bucket to store CloudTrail logs
resource "aws_s3_bucket" "tf_cloudtrail_bucket" {
  bucket = "cloudtrail-logs-bucket-pimiento"
}

resource "aws_s3_bucket_versioning" "cloudwatch_bucket_versioning" {
  bucket = aws_s3_bucket.tf_cloudtrail_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "tf_cloudtrail_bucket_ownership_controls" {
  bucket = aws_s3_bucket.tf_cloudtrail_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# S3 bucket ACL
resource "aws_s3_bucket_acl" "cloudtrail_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.tf_cloudtrail_bucket_ownership_controls]

  bucket = aws_s3_bucket.tf_cloudtrail_bucket.id
  acl    = "private"
}

# Server-side encryption configuration for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_cloudtrail_bucket_encryption" {
  bucket = aws_s3_bucket.tf_cloudtrail_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
