resource "aws_s3_bucket" "prod_website" {
  bucket = "prod-website-${random_string.suffix.result}"

  tags = {
    Environment = "Production"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.prod_website.id  # ✅ Correct reference now
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.prod_website.id  # ✅ Correct reference now

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.prod_website.id  # ✅ Correct reference now

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.prod_website.arn}/*"  # ✅ Correct reference
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website]
}