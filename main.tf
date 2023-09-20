resource "aws_s3_bucket" "terraform_remote_state_bucket" {
  bucket = "terraform-remote-state-${var.project_name}"

  object_lock_enabled = true

  tags = {
    Name = "S3 Remote Terraform State Store for ${var.project_name}"
  }
}

resource "aws_kms_key" "terraform_remote_state_encryption_key" {
  description             = "This key is used to encrypt S3 bucket objects for the ${var.project_name} app"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_remote_state_bucket_sse_config" {
  bucket = aws_s3_bucket.terraform_remote_state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_remote_state_encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_remote_state_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_remote_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock-table-${var.project_name}"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    "Name" = "DynamoDB Terraform State Lock Table"
  }
}
