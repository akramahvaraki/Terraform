provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket         = "depositproof-staging-tf-state-us-west-2"
    key            = "_global/ci-access/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "us-west-2"
    encrypt        = "true"
  }
}