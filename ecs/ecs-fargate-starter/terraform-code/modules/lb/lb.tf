
locals {
  apps_by_name = {
    for app in var.apps : app.task_definition.container.name => app
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_lb" "this" {
  name                       = "my-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [var.subnet1_id, var.subnet2_id]
  enable_deletion_protection = false

  tags = {
    Name = "application-lb-for-ecs"
  }
}

resource "aws_lb_target_group" "app" {
  for_each    = local.apps_by_name
  name        = "${each.key}-tg"
  port        = each.value.task_definition.container.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = each.value.task_definition.container.elb_healthcheck_path
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "${each.key}-target-group"
  }
}

resource "aws_lb_listener" "http" {
  count             = 1
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn


  # DEFAULT BEHAVIOUR IF NOT ACTION FIT TO THE REQUEST< WRONG PATH OR SO
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "apps" {
  for_each = local.apps_by_name

  listener_arn = aws_lb_listener.http[0].arn
  priority     = 100 + index(keys(local.apps_by_name), each.key)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app[each.key].arn
  }

  condition {
    path_pattern {
      values = ["/${each.key}*"]
    }
  }
}
