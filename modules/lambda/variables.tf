variable "access_iam_role_arn" {
  type        = string
  description = "The arn of the Lambda IAM role that should be used."
  default     = "rds-proxy-lambda"
}

variable "api_gateway_execution_arn" {
  type        = string
  description = "The execution arn of the API Gateway instance to link the Lambda function to."
  default     = "rds-proxy-lambda"
}

variable "function_name" {
  type        = string
  description = "The name of the Lambda function that will call the RDS proxy."
  default     = "rds-proxy-lambda"
}

variable "function_handler" {
  type        = string
  description = "The name of the Lambda function handler or the entry point for the Lambda."
  default     = "index.handler"
}

variable "private_subnets" {
  type        = list(string)
  description = "The list of private subnets the Lambda function needs access to."
}

variable "security_group_ids" {
  type        = list(string)
  description = "The list of security group IDs that dictate the access the Lambda function has."
}

variable "source_dir" {
  type        = string
  description = "The source directory where the Lambda function code lives"
  default     = "./lambdas/rds-proxy-GET"
}

variable "timeout" {
  type        = number
  description = "The timeout of the Lambda function."
  default     = 10
}
