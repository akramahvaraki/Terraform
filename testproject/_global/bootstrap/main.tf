provider "aws" {
  region = "us-west-2"
}

module "bootstrap" {
  source        = "trussworks/bootstrap/aws"
  version       = "v5.2.0"
  region        = "us-west-2"
  account_alias = "depositproof-staging"
  log_retention = 30
}
