# Check the document for IP address range and subnetting:
# Dcoument: https://gitlab.com/drbalcony/devops-infra-references/-/blob/main/docs/networking.md

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.16.0"

  name = "app"
  cidr = "10.5.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.5.1.0/24", "10.5.2.0/24", "10.5.3.0/24"]
  public_subnets  = ["10.5.101.0/24", "10.5.102.0/24", "10.5.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}
