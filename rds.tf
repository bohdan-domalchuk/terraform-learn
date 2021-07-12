resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = local.name
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.03.2"
  availability_zones      = data.aws_availability_zones.available.names[count.index]
  database_name           = var.db_name
  master_username         = var.db_user
  master_password         = var.db_password
}
