data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "depositproof-staging-tf-state-us-west-2"
    key    = "us-west-2/vpc/terraform.tfstate"
    region = "us-west-2"
  }
}

module "db" {
  source                               = "terraform-aws-modules/rds/aws"
  identifier                           = "depositproof"
  engine                               = "postgres"
  engine_version                       = "16.3"
  instance_class                       = "db.t4g.micro"
  allocated_storage                    = 20
  db_name                              = "depositproof"
  username                             = "depositproof"
  port                                 = "5432"
  multi_az                             = false
  iam_database_authentication_enabled  = false
  vpc_security_group_ids               = [aws_security_group.db.id]
  maintenance_window                   = "Mon:00:00-Mon:03:00"
  backup_window                        = "03:00-06:00"
  create_db_subnet_group               = true
  subnet_ids                           = data.terraform_remote_state.vpc.outputs.private_subnets
  family                               = "postgres16"
  major_engine_version                 = "16"
  deletion_protection                  = false
  manage_master_user_password_rotation = false
}

resource "aws_security_group" "db" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  name   = "db-depositproof-sg"
  tags = {
    "Name" = "db-depositproof-sg"
  }
}

resource "aws_security_group_rule" "db_ingress" {
  security_group_id = aws_security_group.db.id
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["10.5.0.0/16"]
}

resource "aws_security_group_rule" "db_egress" {
  security_group_id = aws_security_group.db.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
