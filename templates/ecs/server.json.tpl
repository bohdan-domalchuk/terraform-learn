[
  {
    "name": "${app_name}-container",
    "image": "${app_image}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/lw",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
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
