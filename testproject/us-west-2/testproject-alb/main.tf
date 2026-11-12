data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "depositproof-staging-tf-state-us-west-2"
    key    = "us-west-2/vpc/terraform.tfstate"
    region = "us-west-2"
  }
}

data "aws_acm_certificate" "cert" {
  domain   = "depositproof.com"
  statuses = ["ISSUED"]
}

resource "aws_lb" "depositproof" {
  name                       = "depositproof-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = data.terraform_remote_state.vpc.outputs.public_subnets
  enable_deletion_protection = true
}

resource "aws_lb_listener" "redirect" {
  load_balancer_arn = aws_lb.depositproof.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.depositproof.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_target_group" "frontend" {
  name_prefix = "front"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "3000"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 60
  }
}

resource "aws_lb_target_group" "backend" {
  name_prefix = "back"
  port        = 7001
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  health_check {
    path                = "/up"
    protocol            = "HTTP"
    port                = "8000"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 10
    interval            = 60
  }
}

resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
  condition {
    host_header {
      values = ["api.aws-staging.depositproof.dev","api.depositproof.com"]
    }
  }
}
resource "aws_security_group" "alb" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  name   = "depositproof-alb"
  tags = {
    "Name" = "depositproof-alb"
  }
}

resource "aws_security_group_rule" "alb_ingress" {
  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_https_ingress" {
  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_egress" {
  security_group_id = aws_security_group.alb.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
