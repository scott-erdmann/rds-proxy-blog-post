resource "aws_iam_role" "rds_secrets_access_role" {
  name = "RDSAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "RDS Credential Access Role"
  }
}

resource "aws_iam_policy" "rds_creds_access_policy" {
  name = "RDSAccessPolicy"

  description = "IAM policy to access an RDS instance"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "rds:*",
          "rds-db:*"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          #   "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue"
          #   "secretsmanager:DescribeSecret",
          #   "secretsmanager:ListSecretVersionIds",
          #   "secretsmanager:ListSecrets"
        ],
        Effect = "Allow",
        # Resource = "${aws_secretsmanager_secret.rds_credentials.arn}"
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "kms:Decrypt",
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" : "secretsmanager.${var.region}.amazonaws.com"
          }
        }
      },
      {
        Effect   = "Allow",
        Action   = "ec2:Decrypt",
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" : "secretsmanager.${var.region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "rds_creds_access_attachment" {
  name       = "rds_access_attachment"
  policy_arn = aws_iam_policy.rds_creds_access_policy.arn
  roles      = [aws_iam_role.rds_secrets_access_role.name]
}

resource "aws_iam_role" "lambda_access_role" {
  name = "AWSLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_access_policy" {
  name = "AWSLambdaAccessPolicy"

  description = "IAM policy for Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "rds:*",
          "rds-db:*"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_access_attachment" {
  name       = "lambda_access_attachment"
  policy_arn = aws_iam_policy.lambda_access_policy.arn
  roles      = [aws_iam_role.lambda_access_role.name]
}

resource "aws_iam_policy_attachment" "managed_lambda_policy_attachment" {
  name       = "AWSLambdaVPCAccessExecutionRole_attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  roles      = [aws_iam_role.lambda_access_role.name]
}


