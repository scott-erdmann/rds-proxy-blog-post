data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${var.function_name}.zip"
}

resource "aws_lambda_function" "rds_proxy_lambda" {
  filename      = "${var.function_name}.zip"
  function_name = var.function_name
  #   role             = aws_iam_role.lambda_access_role.arn
  role             = var.access_iam_role_arn
  handler          = var.function_handler
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "nodejs16.x"
  timeout          = var.timeout

  vpc_config {
    subnet_ids         = var.private_subnets
    security_group_ids = var.security_group_ids
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_proxy_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}
