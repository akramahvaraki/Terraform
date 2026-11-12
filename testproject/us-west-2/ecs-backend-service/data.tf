data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "depositproof-staging-tf-state-us-west-2"
    key    = "us-west-2/vpc/terraform.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "ecs" {
  backend = "s3"
  config = {
    bucket = "depositproof-staging-tf-state-us-west-2"
    key    = "us-west-2/ecs-cluster/terraform.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "alb" {
  backend = "s3"
  config = {
    bucket = "depositproof-staging-tf-state-us-west-2"
    key    = "us-west-2/depositproof-alb/terraform.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "task" {
  backend = "s3"
  config = {
    bucket = "depositproof-staging-tf-state-us-west-2"
    key    = "us-west-2/ecs-backend-task/terraform.tfstate"
    region = "us-west-2"
  }
}
