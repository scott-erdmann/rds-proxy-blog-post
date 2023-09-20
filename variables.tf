variable "database_name" {
  type        = string
  description = "The name of the database cluster"
  default     = "rds_proxy"
}

variable "db_availability_zones" {
  type        = list(string)
  description = "The availability zones that the RDS instance will be deployed to"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "db_proxy_name" {
  type        = string
  description = "The name of the RDS proxy"
  default     = "demo-rds-proxy"
}

variable "db_master_username" {
  type        = string
  description = "The name of the master password for the RDS instance"
  default     = "rds_proxy"
}

variable "project_name" {
  type        = string
  description = "The name of the project or blog post"
  default     = "rds-proxy-blog-post"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "The region to deploy resources into"
}

variable "rds_db_secret_name" {
  type    = string
  default = "rds/rds-proxy-credentials"
}
