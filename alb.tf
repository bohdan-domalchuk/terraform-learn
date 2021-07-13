resource "aws_alb" "ui" {
  name            = "${local.ui}-load-balancer"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_alb_target_group" "ui" {
  name        = "${local.ui}-target-group"
  port        = var.ui_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.ui_health_check_path
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "ui" {
  load_balancer_arn = aws_alb.ui.id
  port              = var.ui_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.ui.id
    type             = "forward"
  }
}

resource "aws_alb" "server" {
  name            = "${local.server}-load-balancer"
  subnets         = aws_subnet.private.*.id
  security_groups = [aws_security_group.lb.id, aws_security_group.rds.id]
}

resource "aws_alb_target_group" "server" {
  name        = "${local.server}-target-group"
  port        = var.server_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.server_health_check_path
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "server" {
  load_balancer_arn = aws_alb.server.id
  port              = var.server_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.server.id
    type             = "forward"
  }
}
