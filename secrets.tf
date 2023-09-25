resource "aws_secretsmanager_secret" "rds_credentials" {
  name = var.rds_db_secret_name
}

# Uncomment these data resources after the secret has been provisioned and username and password secrets set.

# data "aws_secretsmanager_secret" "rds_db_secret_name" {
#   name = var.rds_db_secret_name
# }

# data "aws_secretsmanager_secret_version" "rds_db_secret_current" {
#   secret_id = data.aws_secretsmanager_secret.rds_db_secret_name.id
# }
