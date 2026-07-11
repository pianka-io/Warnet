resource "aws_s3_bucket" "public_bucket" {
  bucket = "warnet2025-sanctuary"

  tags = {
    Name        = "warnet2025-sanctuary"
    Environment = "Public"
  }
}

resource "aws_s3_bucket" "certs" {
  bucket = "warnet-certs-869935095159"

  tags = {
    Name        = "warnet-certs-869935095159"
    Environment = "Private"
  }
}

resource "aws_s3_bucket_public_access_block" "certs" {
  bucket = aws_s3_bucket.certs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "certs" {
  bucket = aws_s3_bucket.certs.id

  rule {
    apply_server_side_encryption_by_default {
      # AWS-managed aws/s3 key: no extra IAM needed on certbot-ec2-role
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "certs" {
  bucket = aws_s3_bucket.certs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.public_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "PublicReadEverything",
        Effect: "Allow",
        Principal: "*",
        Action: "s3:GetObject",
        Resource: "${aws_s3_bucket.public_bucket.arn}/*"
      }
    ]
  })
}
