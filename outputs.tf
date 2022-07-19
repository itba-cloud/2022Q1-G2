output "api_endpoint" {
  value = aws_api_gateway_stage.this.invoke_url
  description = "The URL to the API Gateway endpoint"
}

output "main_website_endpoint" {
  value = module.s3_main_website.website_endpoint
  description = "The URL to the End User website endpoint"
}

output "stock_website_endpoint" {
  value = module.s3_stock_website.website_endpoint
  description = "The URL to the Stocker website endpoint"
}

output "cloudfront_api_url" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}/api"
  description = "The URL to the API endpoint through Cloudfront"
}


output "cloudfront_end_user_url" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}/"
  description = "The URL to the End User website through Cloudfront"
}

output "cloudfront_stock_url" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}/stock/index.html"
  description = "The URL to the Stocker website through Cloudfront"
}

output "route53_domain_servers" {
  value = aws_route53_zone.main.name_servers
  description = "The URL to Route53 DNS Servers"
}