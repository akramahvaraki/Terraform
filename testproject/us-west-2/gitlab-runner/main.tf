data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "depositproof-staging-tf-state-us-west-2"
    key    = "us-west-2/vpc/terraform.tfstate"
    region = "us-west-2"
  }
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.0"

  name          = "gitlab-runner"
  ami           = var.gitlab_runner_ami
  instance_type = "t3.small"

  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.gitlab_runner.id]

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  user_data = <<-EOF
    #!/bin/bash

    set -e

    # Get a secure string value from Parameter Store and store it in an environment variable
    export RUNNER_TOKEN=$(aws ssm get-parameter --name "${var.runner_token_parameter_name}" \
                                --query Parameter.Value \
                                --with-decryption \
                                --output text)

    if [ -z "$RUNNER_TOKEN" ]; then
      echo "Failed to retrieve the GitLab runner token"
      exit 1
    fi

    sudo gitlab-runner register \
                --non-interactive \
                --url "https://gitlab.com/" \
                --token "$RUNNER_TOKEN" \
                --executor "docker" \
                --docker-privileged \
                --docker-image alpine:latest \
                --description "docker-runner"
  EOF
}

resource "aws_security_group" "gitlab_runner" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  name   = "gitlab-runner"
}

resource "aws_security_group_rule" "gitlab_runner_egress" {
  security_group_id = aws_security_group.gitlab_runner.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
