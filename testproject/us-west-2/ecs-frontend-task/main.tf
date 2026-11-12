module "ecs_container_definition" {
  source                    = "terraform-aws-modules/ecs/aws//modules/container-definition"
  name                      = "depositproof-frontend"
  cloudwatch_log_group_name = "/aws/ecs/depositproof-frontend"

  cpu       = 256
  memory    = 1024
  essential = true
  image     = "${var.image_name}:${var.image_tag}"
  port_mappings = [
    {
      name          = "depositproof"
      containerPort = 3000
      hostPort      = 3000
      protocol      = "tcp"
    }
  ]
  readonly_root_filesystem  = false
  enable_cloudwatch_logging = true
  memory_reservation        = 100
  environment = var.env
  health_check = {
    command      = ["CMD-SHELL", "echo 'container is healthy'"]
    interval     = 30
    timeout      = 5
    start_period = 60
    retries      = 3
  }
}

module "ecs_task" {
  source                = "git::ssh://git@gitlab.com/drbalcony/devops-infra-references//modules/ecs-task-fargate"
  app_name              = "depositproof-frontend"
  cpu                   = 256
  memory                = 1024
  container_definitions = jsonencode([module.ecs_container_definition.container_definition])
}
