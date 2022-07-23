output "api_gateway_resource_id" {
  description = "API GW resource id"
  value = aws_api_gateway_resource.this.id
}

output "api_gateway_method_id" {
  description = "API GW method id"
  value = aws_api_gateway_method.this.id
}

output "api_gateway_integration_id" {
  description = "API GW integration id"
  value = aws_api_gateway_integration.this.id
}