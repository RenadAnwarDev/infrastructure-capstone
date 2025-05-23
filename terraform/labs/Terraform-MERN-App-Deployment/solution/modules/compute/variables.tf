variable "vpc_id" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}
variable "alb_security_group_id" {}
variable "key_name" {
  description = "Name of the SSH key pair to use for instances"
  type        = string
  default     = "mern-key-pair"
}