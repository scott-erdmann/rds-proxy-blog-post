data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "./lambdas/rds-proxy-GET"
  output_path = "${var.lambda_function_name}.zip"
}

resource "aws_lambda_function" "rds_proxy_lambda" {
  filename         = "${var.lambda_function_name}.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_access_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "nodejs16.x"
  timeout          = 15

  vpc_config {
    subnet_ids = [
      aws_subnet.private_subnet_a.id,
      aws_subnet.private_subnet_b.id
    ]
    security_group_ids = [aws_security_group.vpc_main_security_group.id]
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_proxy_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
