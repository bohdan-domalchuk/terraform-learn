[
  {
    "name": "${app_name}-container",
    "image": "${app_image}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": ${app_port},
        "hostPort": ${app_port}
      }
    ],
    "environment": [
      {
        "name": "SPRING_DATASOURCE_URL",
        "value": "${db_url}"
      },
      {
        "name": "SPRING_DATASOURCE_USERNAME",
        "value": "${db_user}"
      },
      {
        "name": "SPRING_DATASOURCE_PASSWORD",
        "value": "${db_password}"
      }
    ]
  }
]
