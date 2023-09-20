module "demo_GET_lambda" {
  source = "./modules/lambda"

  access_iam_role_arn       = aws_iam_role.lambda_access_role.arn
  api_gateway_execution_arn = aws_api_gateway_rest_api.api.execution_arn
  function_name             = "rds-proxy-lambda"
  function_handler          = "index.handler"

  private_subnets = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]

  security_group_ids = [aws_security_group.vpc_main_security_group.id]
  source_dir         = "./lambdas/rds-proxy-GET"
  timeout            = 15
}
