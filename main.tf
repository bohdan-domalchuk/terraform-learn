resource "aws_ecs_cluster" "cluster" {
  name = "domalchuk-cluster"
  tags = local.tags
}

resource "aws_ecs_task_definition" "main" {
  family                   = "ui"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name = "${local.ui}-container"
      image = "domaly/lw-ui:latest"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          protocol = "tcp"
          containerPort = 80
          hostPort = 80
        }]
    }
  ])
}

resource "aws_ecs_service" "main" {
  name                               = "${local.ui}-service"
  cluster                            = aws_ecs_cluster.cluster.id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = aws_security_group.ecs_tasks.*.id
    subnets          = aws_subnet.public.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.id
    container_name   = "${local.ui}-container"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_lb" "main" {
  name               = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = aws_security_group.alb.*.id
  subnets            = [aws_subnet.private[0].id, aws_subnet.public[0].id]
  enable_deletion_protection = false
}

resource "aws_alb_target_group" "main" {
  name        = "${local.name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
     target_group_arn = aws_alb_target_group.main.id
     type             = "forward"
  }
}
