variable "region" {
  default = "eu-north-1"
}

variable "key_name" {
  description = "Name of the SSH key pair to use for instances"
  type        = string
  default     = "sda" # please change to your key name
}
