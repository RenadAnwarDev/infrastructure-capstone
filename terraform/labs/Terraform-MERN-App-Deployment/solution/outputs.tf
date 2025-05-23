output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "frontend_bucket_website_endpoint" {
  value = module.storage.frontend_bucket_website_endpoint
}

output "media_bucket_domain_name" {
  value = module.storage.media_bucket_domain_name
}

output "s3_user_access_key" {
  value     = module.storage.s3_user_access_key
  sensitive = true
}

output "s3_user_secret_key" {
  value     = module.storage.s3_user_secret_key
  sensitive = true
}