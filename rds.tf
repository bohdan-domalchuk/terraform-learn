resource "aws_db_subnet_group" "main" {
  name_prefix = "${local.name}-"
  subnet_ids  = aws_subnet.private.*.id
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier                  = local.name
  engine_mode                         = "serverless"
  engine                              = "aurora-mysql"
  availability_zones                  = data.aws_availability_zones.available.names
  database_name                       = var.db_name
  master_username                     = var.db_user
  master_password                     = var.db_password
  skip_final_snapshot                 = true
  enable_http_endpoint                = true
  db_subnet_group_name                = aws_db_subnet_group.main.name
  vpc_security_group_ids              = [aws_security_group.rds.id]
  iam_database_authentication_enabled = false

  scaling_configuration {
    auto_pause               = true
    max_capacity             = 2
    min_capacity             = 1
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }
}
