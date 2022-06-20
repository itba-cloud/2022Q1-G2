variable "aws_region" {
  description = "AWS Region to be hosted on."
  type = string
  default = "us-east-1"
}

variable "aws_availability_zones" {
  description = "List of AWS Availability Zones to be hosted on."
  type = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1f"]
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type = string
  default     = "10.1.0.0/16"
}

variable "db_name" {
  description = "DB Name"
  type = string
  default = "productsdb"
}

variable "db_username" {
  description = "DB Username"
  type = string
  default = "root"
}

variable "db_password" {
  description = "DB Password"
  type = string
  default = "12345678"
}

variable "domain_name" {
  description = "Domain name"
  type = string
  default = "vending.coke.com"
}