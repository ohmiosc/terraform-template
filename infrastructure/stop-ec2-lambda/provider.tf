provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Product     = "product"
      Environment = "dev"
      Squad       = "infraestructura"
      Project     = "lambda-stop-ec2"
      Creator     = "terraform - Hector"

    }
  }
}

terraform {
  #
  # backend "s3" {}
  backend "s3" {
    bucket = "orbis.terraform.state"
    key    = "temp/terraform/temp/lambda-stop-ec2/terraform.state"
    region = "us-east-1"
  }
  required_version = ">= 0.12.0"
}