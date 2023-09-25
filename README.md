# Terraform template
This template provides all of the terraform code to stand up an API Gateway + Lambda + RDS application. THe template is configured to deploy the stack into a new environment that doesn't have an existing VPC or subnets. If you plan on deploying the solution into an existing environment that already has a VPC set up, then there are going to be several things you can freely omit in your solution.

# The Tech Stack
The tech stack that was used to build this terraform template consists of the following:
    - AWS API Gateway
    - AWS Lambda
    - AWS RDS Proxy
    - AWS RDS
    - AWS IAM
    - AWS KMS
    - AWS Secrets Manager
    - AWS VPC

This template should allow you to provision a scalable API Gateway + Lambda solution that uses an RDS instance as a backend instead of the traditional DynamoDB [serverless] architecture.

If you are provisioning the template into a test account, you will need to provision all of the VPC infrastructure as the RDS/RDS Proxy resources need to be deployed to a private subnet and the Lambda functions need access to these private subnets.

# Deploying into a new environment
If you are deploying these resources to a new envrionment, you are going to need to comment out all terraform code and deploy the `backend.tf` file first. This file contains the resources needed to track the terraform state for your infrastructure.

After commenting out the all terraform code, you are going to need to comment out the `backend` block from the terraform configuration like this:

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.16.0"
    }
  }

  required_version = ">= 1.5"

  #backend "s3" {
  #  bucket         = "terraform-remote-state-rds-proxy-blog-post"
  #  key            = "dev/us-east-1/terraform.tfstate"
  #  region         = "us-east-1"
  #  encrypt        = true
  #  dynamodb_table = "terraform-lock-table-rds-proxy-blog-post"
  #}
}
```

After you've provisoned all of the infrastructure in the `backend.tf` file, you should uncomment the `backend "s3"` terraform block and run `terraform init` once again. You'll be prompted with a message asking if you'd like to copy the existing state to the new backend. Type "yes" and continue.

Now that you have your backend setup, you can freely provision the rest of the resources within the repo to setup your API Gateway + Lambda + RDS/RDS Proxy application stack.

# Recommended Resource Provisioning Order
Due to various dependencies within the set of resources that make up the terraform template, the resources should be provisioned in the following order.

## First round of provisioning
The first round of provisioning should include everything in the following files:
    - `ec2.tf`
    - `vpc.tf`
    - `kms.tf`
    - `secrets.tf` (resource only, not data resources)
    - `api-gateway.tf` (everything except for the commented out resources)

## Second round of provisioning
The second round of provisioning should include everything in the following files:
    - `main.tf` (requires running `terraform init` again)
    - `secrets.tf` (data resources, set a username and password in the secret's value)
    - `rds.tf`

## Third round of provisioning
    - `api-gateway.tf` (everything else)
