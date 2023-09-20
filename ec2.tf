resource "aws_security_group" "vpc_main_security_group" {
  name        = "vpc-main-sg"
  description = "Security group for main VPC"
  vpc_id      = aws_vpc.vpc_main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_cluster" {
  name        = "rds-postgres-cluster-sg"
  description = "Allow VPC traffic to RDS"
  vpc_id      = aws_vpc.vpc_main.id

  ingress {
    description     = "TLS from VPC"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]
    security_groups = [aws_security_group.rds_proxy.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "rds_proxy" {
  name        = "rds-postgres-proxy-sg"
#   description = "Allows VPC traffic to RDS from the proxy"
  description = "Allow Postgres traffic to rds from proxy"
  vpc_id      = aws_vpc.vpc_main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


