data "aws_secretsmanager_secret" "rds_db_secret_name" {
  name = var.rds_db_secret_name
}

data "aws_secretsmanager_secret_version" "rds_db_secret_current" {
  secret_id = data.aws_secretsmanager_secret.rds_db_secret_name.id
}

resource "aws_db_subnet_group" "default" {
  name = "vpc-main-private-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet_b.id,
    aws_subnet.private_subnet_a.id
  ]
}

resource "aws_rds_cluster" "rds_cluster" {
  depends_on         = [aws_secretsmanager_secret.rds_credentials]
  cluster_identifier = var.project_name
  database_name      = var.database_name
  master_username    = var.db_master_username
  master_password    = "thisisafakepassword"
  #   master_password                     = jsondecode(data.aws_secretsmanager_secret_version.rds_db_secret_current)["password"]
  engine                              = "aurora-postgresql"
  engine_mode                         = "provisioned"
  engine_version                      = "13.6"
  storage_encrypted                   = true
  kms_key_id                          = aws_kms_key.rds_proxy.arn
  vpc_security_group_ids              = [aws_security_group.rds_cluster.id]
  db_subnet_group_name                = aws_db_subnet_group.default.id
  availability_zones                  = var.db_availability_zones
  iam_database_authentication_enabled = true
  skip_final_snapshot                 = true
  final_snapshot_identifier           = "${var.project_name}-snapshot"

  serverlessv2_scaling_configuration {
    max_capacity = 2.0
    min_capacity = 1.0
  }
}

# RDS Cluster Instance - This can be expanded to provision multiple x number of instances.
resource "aws_rds_cluster_instance" "rds_instance" {
  identifier          = "${var.project_name}-demo-1"
  cluster_identifier  = aws_rds_cluster.rds_cluster.id
  instance_class      = "db.serverless"
  engine              = aws_rds_cluster.rds_cluster.engine
  engine_version      = aws_rds_cluster.rds_cluster.engine_version
  publicly_accessible = false
}

resource "aws_db_proxy" "rds_proxy" {
  name                   = var.db_proxy_name
  debug_logging          = true
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = aws_iam_role.rds_secrets_access_role.arn
  vpc_security_group_ids = [aws_security_group.rds_proxy.id]
  vpc_subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id,
  ]

  auth {
    auth_scheme = "SECRETS"
    description = "example"
    iam_auth    = "REQUIRED"
    secret_arn  = aws_secretsmanager_secret.rds_credentials.arn
  }
}

# RDS Proxy Target Group
resource "aws_db_proxy_default_target_group" "default_target_group" {
  db_proxy_name = aws_db_proxy.rds_proxy.name

  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 100
    max_idle_connections_percent = 50
  }
}

# RDS Proxy Target
resource "aws_db_proxy_target" "demo" {
  db_cluster_identifier = aws_rds_cluster.rds_cluster.id
  db_proxy_name         = aws_db_proxy.rds_proxy.name
  target_group_name     = aws_db_proxy_default_target_group.default_target_group.name
}
