data "terraform_remote_state" "alb" {
  backend = "s3"

  config {
    bucket = "up-terraform-state-${local.region}"
    key    = "production/ecs_loadbalancer/terraform.tfstate"
    region = "${local.region}"
  }
}

data "terraform_remote_state" "account" {
  backend = "s3"

  config {
    bucket = "up-terraform-state-${local.region}"
    key    = "production/ecs_loadbalancer/terraform.tfstate"
    region = "${local.region}"
  }
}

data "aws_cloudformation_stack" "vpc" {
  name = "up-production-ireland-vpc"
}

data "aws_caller_identity" "current" {}