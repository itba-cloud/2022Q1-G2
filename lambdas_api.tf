# ---------------------------------------------------------------------------
# Amazon API Gateway
# ---------------------------------------------------------------------------

resource "aws_api_gateway_rest_api" "this" {
  provider = aws
  name = "aws_api_gateway_lambdas"
}

resource "aws_api_gateway_deployment" "this" {
  provider = aws

  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode(concat(
      [for o in module.api_lambda_functions : o.api_gateway_integration_id],
      [for o in module.api_lambda_functions : o.api_gateway_method_id],
      [for o in module.api_lambda_functions : o.api_gateway_resource_id]
    )))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  provider = aws

  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "api"
}

module "api_lambda_functions" {
  source = "./modules/api_lambda_functions"

  for_each = local.lambda.functions

  api_call              = each.value.api_call
  api_gateway_parent_id = aws_api_gateway_rest_api.this.root_resource_id
  api_gateway_rest_id   = aws_api_gateway_rest_api.this.id
  filename              = each.value.filename
  handler               = each.value.handler
  resource_path         = local.lambda.path
  runtime               = local.lambda.runtime

  environment_variables = {
    DB_ENDPOINT = aws_rds_cluster.aurora.endpoint
    DB_PORT = aws_rds_cluster.aurora.port
    DB_NAME = aws_rds_cluster.aurora.database_name
    DB_USER = aws_rds_cluster.aurora.master_username
    DB_PASS = aws_rds_cluster.aurora.master_password
  }

  security_groups = [aws_security_group.egress_all.id, aws_security_group.https.id]
  subnets = [for o in aws_subnet.private_app : o.id]
}