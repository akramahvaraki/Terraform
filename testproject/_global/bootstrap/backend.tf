terraform {
  backend "s3" {
    bucket         = "depositproof-staging-tf-state-us-west-2"
    key            = "_global/bootstrap/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "us-west-2"
    encrypt        = "true"
  }
}
