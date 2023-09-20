resource "aws_secretsmanager_secret" "rds_credentials" {
  name = var.rds_db_secret_name
}
