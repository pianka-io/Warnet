resource "aws_s3_bucket" "public_bucket" {
  bucket = "warnet2025-sanctuary"

  tags = {
    Name        = "warnet2025-sanctuary"
    Environment = "Public"
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
