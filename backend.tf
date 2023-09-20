# Copyright (c) Scott Erdmann
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.16.0"
    }
  }

  required_version = ">= 1.5"

  backend "s3" {
    bucket         = "terraform-remote-state-rds-proxy-blog-post"
    key            = "dev/us-east-1/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table-rds-proxy-blog-post"
  }
}

provider "aws" {
  region = var.region
}
