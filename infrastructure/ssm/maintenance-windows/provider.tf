provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Product     = "product"
      Environment = "dev"
      Squad       = "infraestructura"
      Project     = "stop-ssm"
      Owner       = "pe"

    }
  }
}

terraform {
  #
  # backend "s3" {}
  backend "s3" {
    bucket = "orbis.terraform.state"
    key    = "temp/terraform/temp/ssm-maintenance/terraform.state"
    region = "us-east-1"
  }
  required_version = ">= 0.12.0"
}