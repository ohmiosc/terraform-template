provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Product     = "product"
      Environment = "prod"
      Squad       = "infraestructura"
      Project     = "lambda-backup-ec2"
      Creator     = "terraform"

    }
  }
}

terraform {
  #
  # backend "s3" {}
  backend "s3" {
    bucket = "pyme.terraform.state"
    key    = "temp/terraform/temp/lambda-backup-ec2/terraform.state"
    region = "us-east-1"
  }
  required_version = ">= 0.12.0"
}