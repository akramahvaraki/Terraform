locals {
  services = [
    "frontend",
    "backend"
  ]
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "2.3.0"

  for_each = { for service in local.services : service => service }

  repository_name               = "depositproof-${each.key}-staging"
  repository_image_scan_on_push = false
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
  tags = {
    Terraform   = "true"
    Environment = "staging"
    Application = each.key
    Team        = "depositproof"
  }
}
