output "frontend_bucket_name" {
  description = "Name of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.id
}

output "frontend_bucket_website_endpoint" {
  description = "Website endpoint for the frontend bucket"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "media_bucket_name" {
  description = "Name of the media S3 bucket"
  value       = aws_s3_bucket.media.id
}

output "media_bucket_domain_name" {
  description = "Domain name for the media bucket"
  value       = aws_s3_bucket.media.bucket_regional_domain_name
}

output "s3_user_access_key" {
  description = "Access key for the S3 IAM user"
  value       = aws_iam_access_key.s3_user.id
  sensitive   = true
}

output "s3_user_secret_key" {
  description = "Secret key for the S3 IAM user"
  value       = aws_iam_access_key.s3_user.secret
  sensitive   = true
} 