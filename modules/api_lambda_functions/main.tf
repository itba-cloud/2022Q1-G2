# ---------------------------------------------------------------------------
# AWS Lambda + AWS API Gateway
# ---------------------------------------------------------------------------


# --- API GATEWAY ---

resource "aws_api_gateway_resource" "this" {
  path_part   = var.api_call
  parent_id   = var.api_gateway_parent_id
  rest_api_id = var.api_gateway_rest_id
}

resource "aws_api_gateway_method" "this" {
  rest_api_id   = var.api_gateway_rest_id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = var.method
  authorization = var.authorization
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = var.api_gateway_rest_id
  resource_id             = aws_api_gateway_resource.this.id
  http_method             = aws_api_gateway_method.this.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.this.invoke_arn
}

# --- LAMBDA ---

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.api_gateway_rest_id}/*/${aws_api_gateway_method.this.http_method}${aws_api_gateway_resource.this.path}"
}

resource "aws_lambda_function" "this" {
  function_name    = "VendingMachineLambda-${replace(var.filename, ".zip", "")}"
  filename         = "${var.resource_path}/${var.filename}"
  source_code_hash = filebase64sha256("${var.resource_path}/${var.filename}")
  role             = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler          = var.handler
  runtime          = var.runtime

  environment {
    variables = var.environment_variables
  }

  vpc_config {
    security_group_ids = var.security_groups
    subnet_ids         = var.subnets
  }
}