resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/lw"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "${local.name}-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}

