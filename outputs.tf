output "api_endpoint" {
  value = aws_api_gateway_stage.this.invoke_url
}

output "main_website_endpoint" {
  value = module.s3_main_website.website_endpoint
}

output "stock_website_endpoint" {
  value = module.s3_stock_website.website_endpoint
}

output "cloudfront_api_url" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}/api"
}


output "cloudfront_end_user_url" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}/"
}

output "cloudfront_stock_url" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}/stock/index.html"
}

output "route53_domain_servers" {
  value = aws_route53_zone.main.name_servers
}