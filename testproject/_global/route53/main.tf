data "terraform_remote_state" "alb" {
  backend = "s3"
  config = {
    bucket = "depositproof-staging-tf-state-us-west-2"
    key    = "us-west-2/depositproof-alb/terraform.tfstate"
    region = "us-west-2"
  }
}

module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 3.0"

  zones = {
    "aws-staging.depositproof.dev" = {
      comment = "Route 53 zone for the depositproof staging environment"
      tags = {
        env = "staging"
      }
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 3.0"

  zone_name = keys(module.zones.route53_zone_zone_id)[0]

  records = [
    {
      name = "app"
      type = "A"
      alias = {
        name    = data.terraform_remote_state.alb.outputs.alb_dns_name
        zone_id = data.terraform_remote_state.alb.outputs.alb_zone_id
      }
    },
    {
      name = "api"
      type = "A"
      alias = {
        name    = data.terraform_remote_state.alb.outputs.alb_dns_name
        zone_id = data.terraform_remote_state.alb.outputs.alb_zone_id
      }
    }

  ]

  depends_on = [module.zones]
}
