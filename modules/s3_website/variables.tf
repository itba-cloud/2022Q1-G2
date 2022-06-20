# ------------------------------------------------------------------------
# Amazon S3 variables
# ------------------------------------------------------------------------

variable "bucket_name" {
  type        = string
  description = "The name of the bucket. Must be less than or equal to 63 characters in length."
}

variable "export_path" {
  type        = string
  description = "Path to the resources folder."
}

variable "website_tier" {
  type        = string
  description = "Tier of the main website's bucket"
  default     = "STANDARD"
}

variable "log_tier" {
  type        = string
  description = "Tier of the logs' bucket"
  default     = "GLACIER_IR"
}

variable "index_document" {
  type        = string
  description = "Index document name"
}

variable "error_document" {
  type        = string
  description = "Error document name"
}

variable "cloudfront_origin_access_identity" {
  description = "Cloudfront access origin id"
}

