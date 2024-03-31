
resource "aws_ecs_cluster" "nginx" {
  name = "nginx-test"
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx-test-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_mem

  container_definitions = <<DEFINITION
[
  {
    "image": "nginx",
    "cpu": ${var.ecs_cpu},
    "memory": ${var.ecs_mem},
    "name": "${var.ecs_container_name}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
DEFINITION
}

# setup backend ecs service at private subnet
resource "aws_ecs_service" "nginx" {
  name            = "nginx-ecs"
  cluster         = aws_ecs_cluster.nginx.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.nginx.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx.id
    container_name   = var.ecs_container_name
    container_port   = 80
  }

  depends_on = [aws_lb_listener.nginx]
}