variable "aws_region" {
  description = "AWS Region to be hosted on."
  type = string
  default = "us-east-1"
}

variable "availability_zones_count" {
  description = "Amount of availability zones to deploy to"
  type = number
  default = 3
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "db_name" {
  description = "DB Name"
  type        = string
  sensitive   = true
  default     = "productsdb"
}

variable "db_username" {
  description = "DB Username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "DB Password"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Domain name"
  type        = string
  default     = "vending.coke.com"
}