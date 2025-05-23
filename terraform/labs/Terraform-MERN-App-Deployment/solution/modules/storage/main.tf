/*
  Storage Module - Creates S3 buckets for frontend static website hosting 
  and media file storage, along with IAM user for S3 access.
*/

# Generate a random string to ensure globally unique bucket names
resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

# Define bucket names with random suffix to ensure uniqueness
locals {
  frontend_bucket_name = "${var.frontend_bucket_name}-${random_string.random.result}"
  media_bucket_name    = "${var.media_bucket_name}-${random_string.random.result}"
}

# S3 bucket for hosting the React frontend as a static website
resource "aws_s3_bucket" "frontend" {
  bucket        = local.frontend_bucket_name
  force_destroy = true  # Allow Terraform to delete the bucket even if it contains objects
  tags = {
    Name = "MERN Frontend"
  }
}

# Configure the frontend bucket for static website hosting
resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  # Default page served when accessing the website
  index_document {
    suffix = "index.html"
  }

  # Page to serve when an error occurs (SPA routing support)
  error_document {
    key = "index.html"
  }
}

# Configure public access settings for the frontend bucket
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  # Allow public access since it's a public website
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Add a bucket policy to allow public read access to the frontend files
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"  # Allow anyone to read
        Action    = "s3:GetObject"  # Allow only read operations
        Resource  = "${aws_s3_bucket.frontend.arn}/*"  # Apply to all objects in bucket
      }
    ]
  })

  # Ensure the policy is applied after the public access block is configured
  depends_on = [aws_s3_bucket_public_access_block.frontend]
}

# S3 bucket for storing media uploads (images, etc.)
resource "aws_s3_bucket" "media" {
  bucket        = local.media_bucket_name
  force_destroy = true  # Allow Terraform to delete the bucket even if it contains objects
  tags = {
    Name = "MERN Media"
  }
}

# Configure CORS for the media bucket to allow frontend access
resource "aws_s3_bucket_cors_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  # CORS rules to allow frontend to interact with the bucket
  cors_rule {
    allowed_headers = ["*"]  # Allow all headers
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]  # Allow all common HTTP methods
    allowed_origins = ["*"]  # Allow all origins (restrict in production)
    expose_headers  = ["ETag"]  # Expose ETag for file verification
    max_age_seconds = 3000  # Cache CORS preflight results
  }
}

# Configure public access settings for the media bucket
resource "aws_s3_bucket_public_access_block" "media" {
  bucket = aws_s3_bucket.media.id

  # Allow public access for media files
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Add a bucket policy to allow public read access to media files
resource "aws_s3_bucket_policy" "media" {
  bucket = aws_s3_bucket.media.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"  # Allow anyone to read
        Action    = "s3:GetObject"  # Allow only read operations
        Resource  = "${aws_s3_bucket.media.arn}/*"  # Apply to all objects in bucket
      }
    ]
  })

  # Ensure the policy is applied after the public access block is configured
  depends_on = [aws_s3_bucket_public_access_block.media]
}

# Create an IAM user for programmatic access to S3 media bucket
resource "aws_iam_user" "s3_user" {
  name = "mern-app-s3-user"  # Name of the IAM user
}

# Generate access keys for the IAM user
resource "aws_iam_access_key" "s3_user" {
  user = aws_iam_user.s3_user.name  # Associate with the IAM user
}

# Create a policy to grant permissions to the S3 bucket
resource "aws_iam_user_policy" "s3_user_policy" {
  name = "s3-media-policy"  # Name of the policy
  user = aws_iam_user.s3_user.name  # Associate with the IAM user

  # Define the permissions for the user
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",    # Upload files
          "s3:GetObject",    # Download files
          "s3:DeleteObject", # Delete files
          "s3:ListBucket"    # List files
        ]
        Resource = [
          aws_s3_bucket.media.arn,              # Bucket itself (for listing)
          "${aws_s3_bucket.media.arn}/*"        # Objects in the bucket
        ]
      }
    ]
  })
} 