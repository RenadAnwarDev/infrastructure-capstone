variable "frontend_bucket_name" {
  description = "Name of the S3 bucket for frontend static website hosting"
  type        = string
  default     = "mern-frontend"
}

variable "media_bucket_name" {
  description = "Name of the S3 bucket for media storage"
  type        = string
  default     = "mern-media"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
} 