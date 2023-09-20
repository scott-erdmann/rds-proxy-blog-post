output "lambda_invoke_arn" {
  value = aws_lambda_function.rds_proxy_lambda.invoke_arn
}
