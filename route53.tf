resource "aws_route53_zone" "main" {
  name = var.domain_name
}

resource "aws_route53_record" "root_domain" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_zone" "www" {
  name = "www.${var.domain_name}"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.www.zone_id
  name    = var.domain_name
  type    = "CNAME"
  ttl     = 172800

  records = [var.domain_name]
}
