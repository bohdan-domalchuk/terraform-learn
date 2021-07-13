resource "aws_ecs_cluster" "lw" {
  name = "${local.name}-cluster"
}

data "template_file" "ui" {
  template = file("./templates/ecs/ui.json.tpl")

  vars = {
    app_name       = local.ui
    app_image      = var.ui_image
    app_port       = var.ui_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
    server         = aws_alb.server.dns_name
  }

  depends_on = [aws_ecs_service.server]
}

resource "aws_ecs_task_definition" "ui" {
  family                   = "${local.ui}-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.ui.rendered
}

resource "aws_ecs_service" "ui" {
  name            = "${local.ui}-service"
  cluster         = aws_ecs_cluster.lw.id
  task_definition = aws_ecs_task_definition.ui.arn
  desired_count   = var.ui_instance_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.ui.id
    container_name   = "${local.ui}-container"
    container_port   = var.ui_port
  }

  depends_on = [
    aws_alb_listener.ui,
    aws_iam_role_policy_attachment.ecs_task_execution_role,
    aws_ecs_service.server
  ]
}

data "template_file" "server" {
  template = file("./templates/ecs/server.json.tpl")

  vars = {
    app_name       = local.server
    app_image      = var.server_image
    app_port       = var.server_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
    db_url         = "jdbc:mysql://${aws_rds_cluster.aurora.endpoint}:${aws_rds_cluster.aurora.port}/${aws_rds_cluster.aurora.database_name}?useSSL=false&allowPublicKeyRetrieval=true"
    db_user        = var.db_user
    db_password    = var.db_password
  }
}

resource "aws_ecs_task_definition" "server" {
  family                   = "${local.server}-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.server.rendered
}

resource "aws_ecs_service" "server" {
  name            = "${local.server}-service"
  cluster         = aws_ecs_cluster.lw.id
  task_definition = aws_ecs_task_definition.server.arn
  desired_count   = var.server_instance_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id, aws_security_group.rds.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.server.id
    container_name   = "${local.server}-container"
    container_port   = var.server_port
  }

  depends_on = [aws_rds_cluster.aurora, aws_iam_role_policy_attachment.ecs_task_execution_role, aws_alb_listener.server]
}
