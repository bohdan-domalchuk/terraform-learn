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
    ]
  }
]
