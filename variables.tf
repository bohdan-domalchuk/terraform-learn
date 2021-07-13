variable "aws_region" {
  default = "eu-central-1"
}

variable "ecs_task_execution_role_name" {
  default = "myEcsTaskExecutionRole"
}

variable "az_count" {
  default = "2"
}

variable "ui_image" {
  default = "domaly/lw-ui:latest"
}

variable "server_image" {
  default = "domaly/server:latest"
}

variable "ui_port" {
  default = 80
}

variable "server_port" {
  default = 8080
}

variable "ui_instance_count" {
  default = 1
}

variable "server_instance_count" {
  default = 1
}

variable "ui_health_check_path" {
  default = "/"
}

variable "server_health_check_path" {
  default = "/actuator/health"
}

variable "fargate_cpu" {
  default = "1024"
}

variable "fargate_memory" {
  default = "2048"
}

variable "db_user" {
  default = "domalchuk"
}

variable "db_password" {
  default = "Password000#"
}

variable "db_name" {
  default = "lw"
}
