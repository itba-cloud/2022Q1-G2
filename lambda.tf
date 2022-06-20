# ---------------------------------------------------------------------------
# AWS Lambda resources
# ---------------------------------------------------------------------------

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  for_each = local.lambda.functions

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this[each.key].function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*/${aws_api_gateway_method.this[each.key].http_method}${aws_api_gateway_resource.this[each.key].path}"
}

resource "aws_lambda_function" "this" {
  for_each = local.lambda.functions

  function_name    = "VendingMachineLambda-${replace(each.value.filename, ".zip", "")}"
  filename         = "${local.lambda.path}/${each.value.filename}"
  source_code_hash = filebase64sha256("${local.lambda.path}/${each.value.filename}")
  role             = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  handler          = each.value.handler
  runtime          = local.lambda.runtime

  environment {
    variables = {
      DB_ENDPOINT = aws_rds_cluster.aurora.endpoint
      DB_PORT = aws_rds_cluster.aurora.port
      DB_NAME = aws_rds_cluster.aurora.database_name
      DB_USER = aws_rds_cluster.aurora.master_username
      DB_PASS = aws_rds_cluster.aurora.master_password
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.egress_all.id, aws_security_group.https.id]
    subnet_ids         = [for o in aws_subnet.lambda : o.id]
  }
}