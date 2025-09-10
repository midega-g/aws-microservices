variable "default_tags" {
  type        = map(string)
  description = "Default tags for all resources"
  default = {
    "project" = "learning-live-with-aws-hashicorp"
  }
}


variable "region" {
  type        = string
  description = "AWS region for resources"
  default     = "af-south-1"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.255.0.0/20"
}

variable "public_subnet_count" {
  type        = number
  description = "Number of public subnets to create"
  default     = 2
}

variable "private_subnet_count" {
  type        = number
  description = "Number of private subnets to create"
  default     = 2
}