locals {
  s3_user_origin_id = "s3_user"
  s3_stock_origin_id = "s3_stock"
  api_origin_id = "apigw"
}

resource "aws_cloudfront_origin_access_identity" "user" {
  comment = "cloud-vending-machine"
}

resource "aws_cloudfront_origin_access_identity" "stock" {
  comment = "cloud-vending-machine"
}

resource "aws_cloudfront_distribution" "s3_distribution" {

  # An origin is the location where content is stored, and from which CloudFront gets content to serve to viewers.
  origin {
    domain_name = module.s3_main_website.bucket_regional_domain_name
    origin_id   = local.s3_user_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.user.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = module.s3_stock_website.bucket_regional_domain_name
    origin_id   = local.s3_stock_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.stock.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name =  "${aws_api_gateway_rest_api.this.id}.execute-api.${var.aws_region}.amazonaws.com"
    origin_id   = local.api_origin_id

        custom_origin_config {
			http_port              = 80
			https_port             = 443
			origin_protocol_policy = "https-only"
			origin_ssl_protocols   = ["TLSv1","TLSv1.1"]
    }

    # Use S3OriginConfig to specify an Amazon S3 bucket that is not configured with static website hosting.
#    s3_origin_config {
#      origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
#    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Vending Machine main cloudfront"
  default_root_object = "index.html"

# The logging configuration that controls how logs are written to your distribution (maximum one).
#  logging_config {
#    include_cookies = false
#    bucket          = "mylogs.s3.amazonaws.com"
#    prefix          = "myprefix"
#  }

## Extra CNAMEs (alternate domain names), if any, for this distribution.
#  aliases = ["vending.coke.com"]


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_user_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern     = format("/%s/*", aws_api_gateway_stage.this.stage_name)
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.api_origin_id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

    ordered_cache_behavior {
    path_pattern     = "stock/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_stock_origin_id

#      lambda_function_association { TODO: No se puede usar, ya que el lab no permite crear manejar Roles
#        event_type   = "origin-request"
#        lambda_arn = "${aws_lambda_function.lambda_edge.arn}:${aws_lambda_function.lambda_edge.version}"
#        include_body = false
#      }

      forwarded_values {
        query_string = false

        cookies {
          forward = "none"
        }
      }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"


  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["AR"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  depends_on = [module.s3_main_website, module.s3_stock_website, aws_api_gateway_deployment.this]
}

###
# TODO: No se puede usar con los roles del lab
###
#resource "aws_lambda_function" "lambda_edge" {
#  function_name = local.cloudfront.lambda_edge.function_name
#  filename = local.cloudfront.lambda_edge.filename
#  runtime       = "nodejs16.x"
#  handler       = local.cloudfront.lambda_edge.handler
#  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
##   role = aws_iam_role.lambda_edge_role.arn
#   source_code_hash = filebase64sha256(local.cloudfront.lambda_edge.filename)
#  publish = true
#}
#resource "aws_iam_role" "lambda_edge_role" {
#  name = "lambda-edge-role"
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Sid": "",
#      "Effect": "Allow",
#      "Principal": {
#        "Service": [
#          "lambda.amazonaws.com",
#          "edgelambda.amazonaws.com"
#        ]
#      },
#      "Action": "sts:AssumeRole"
#    }
#  ]
#}
#EOF
#}
