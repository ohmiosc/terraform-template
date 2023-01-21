provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Product     = "cross"
      Environment = "prod"
      Squad       = "Cloud Engineer"
      Project     = "lambda-stop-ec2"
      Iac     = "terraform"

    }
  }
}

terraform {
  #
  # backend "s3" {}
  backend "s3" {
    bucket = "orbis.terraform.state"
    key    = "infraestructure/production/lambda-stop-ec2/terraform.state"
    region = "us-east-1"
  }
  required_version = ">= 0.12.0"
}