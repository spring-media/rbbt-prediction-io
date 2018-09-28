provider "aws" {
  region = "eu-west-1"
}

terraform {
  required_version = ">= 0.11.0"

  backend "s3" {
    bucket         = "up-terraform-state-eu-west-1"
    key            = "production/prediction_io/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-lock-table"
  }
}
