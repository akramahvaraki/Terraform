module "ecs_cluster" {
  source  = "cloudposse/ecs-cluster/aws"
  version = "0.9.0"

  name                            = "depositproof-staging"
  container_insights_enabled      = false
  capacity_providers_fargate      = true
  capacity_providers_fargate_spot = false
}
