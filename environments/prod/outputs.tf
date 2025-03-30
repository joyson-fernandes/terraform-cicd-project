output "prod_website_bucket_id" {
  value = aws_s3_bucket.prod_website.id
}

output "prod_website_bucket_arn" {
  value = aws_s3_bucket.prod_website.arn
}