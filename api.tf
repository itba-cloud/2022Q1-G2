# ---------------------------------------------------------------------------
# Amazon API Gateway
# ---------------------------------------------------------------------------

resource "aws_api_gateway_rest_api" "this" {
  name        = "aws_api_gateway"
}

resource "aws_api_gateway_resource" "this" {
  for_each = local.lambda.functions

  path_part   = each.value.api_call
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_method" "this" {
  for_each = local.lambda.functions

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this[each.key].id
  http_method   = each.value.method
  authorization = each.value.authorization
}

resource "aws_api_gateway_integration" "this" {
  for_each = local.lambda.functions

  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this[each.key].id
  http_method             = aws_api_gateway_method.this[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.this[each.key].invoke_arn
}

#resource "aws_api_gateway_rest_api_policy" "" {
#  policy      = ""
#  rest_api_id = ""
#}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode(concat(
      [for o in aws_api_gateway_resource.this : o.id],
      [for o in aws_api_gateway_method.this : o.id],
      [for o in aws_api_gateway_integration.this : o.id]
    )))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "api"
}