/*
  Main Terraform configuration file that sets up the AWS provider
  and integrates all the modules for the MERN stack infrastructure.
*/

# Configure the AWS provider with the desired region
provider "aws" {
  region = "eu-north-1"
}

# VPC Module - Creates the networking foundation
# Includes VPC, subnets, internet gateway, and route tables
module "vpc" {
  source = "./modules/vpc"
}

# Security Module - Sets up security groups and IAM roles
# Controls inbound/outbound traffic for EC2 instances and ALB
module "security" {
  source            = "./modules/security"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

# Compute Module - Creates EC2 instances, ALB, ASG
# Handles the infrastructure for running the backend application
module "compute" {
  source                = "./modules/compute"
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  security_group_id     = module.security.security_group_id
  alb_security_group_id = module.security.alb_security_group_id
  key_name              = var.key_name
}

# Storage Module - Creates S3 buckets for frontend and media
# Sets up proper permissions, CORS, and IAM user for access
module "storage" {
  source = "./modules/storage"
}