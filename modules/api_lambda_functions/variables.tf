# ---------------------------------------------------------------------------
# Lambda + API Gateway Variables
# ---------------------------------------------------------------------------

variable "resource_path" {
  type = string
  description = "Path to the resource file where the lambda code is located."
}

variable "runtime" {
  type = string
  description = "Lambda's Runtime"
}

variable "filename" {
  type        = string
  description = "Function's file name"
}

variable "handler" {
  type = string
  description = "Function's handler"
}

variable "api_call" {
  type = string
  description = "Function's API GW endpoint call"
}

variable "method" {
  type = string
  default = "GET"
  description = "Function's API GW method"
}

variable "authorization" {
  type = string
  default = "NONE"
  description = "Function's Authorization type"
}

variable "environment_variables" {
  type = map(any)
  default = {}
  description = "Lambda's Environment variables"
}

variable "security_groups" {
  type = list(any)
  default = []
  description = "Lambda's security group IDs"
}

variable "subnets" {
  type = list(any)
  default = []
  description = "Lambda's subnets IDs"
}

variable "api_gateway_parent_id" {
  type = string
  description = "The aws_api_gateway_rest_api.this.parent_id"
}

variable "api_gateway_rest_id" {
  type = string
  description = "The aws_api_gateway_rest_api.this.api_gateway_rest_id"
}

