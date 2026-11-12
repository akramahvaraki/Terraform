module "ecs_service" {
  source                         = "terraform-aws-modules/ecs/aws//modules/service"
  name                           = "frontend-service"
  cluster_arn                    = data.terraform_remote_state.ecs.outputs.ecs_cluster_arn
  task_definition_arn            = data.terraform_remote_state.task.outputs.task_definition_arn
  create_task_definition         = false
  assign_public_ip               = true
  enable_autoscaling             = false
  enable_execute_command         = true
  subnet_ids                     = data.terraform_remote_state.vpc.outputs.public_subnets
  ignore_task_definition_changes = true

  load_balancer = {
    service = {
      target_group_arn = data.terraform_remote_state.alb.outputs.frontend_target_group_arn
      container_name   = "depositproof-frontend"
      container_port   = "3000"
    }
  }

  security_group_rules = {
    ingress_3000 = {
      type        = "ingress"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
