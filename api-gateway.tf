resource "aws_api_gateway_rest_api" "api" {
  name = var.api_gateway_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "proxy_endpoint" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "rds_proxy"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy_endpoint.id
  http_method   = "GET"
  authorization = "NONE"
}

# Uncomment and provison after the Lambda function has been provisioned.
resource "aws_api_gateway_deployment" "proxy_deployment" {
  depends_on = [
    aws_api_gateway_rest_api.api,
    aws_api_gateway_method.proxy_method,
    aws_api_gateway_integration.proxy_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.proxy_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"
}

resource "aws_api_gateway_integration" "proxy_integration" {
  depends_on              = [module.demo_GET_lambda]
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.proxy_endpoint.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.demo_GET_lambda.lambda_invoke_arn
}
