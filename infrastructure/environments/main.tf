/******************************************************************************
* ECS Cluster
*
* Create ECS Cluster and its supporting services, in this case EC2 instances in
* and Autoscaling group.
*
* *****************************************************************************/


resource "aws_ecs_cluster" "cluster" {
  name = "${var.app_name}-${var.environment}"

  tags = {
    Application = "${var.app_name}"
    Environment = var.environment
    Resource    = "modules.ecs.cluster.aws_ecs_cluster.cluster"
  }

  depends_on = [
    aws_vpc.main_vpc,
  ]
}


/**
* Create the task definition for the app backend, in this case a thin
* wrapper around the container definition.
*/
resource "aws_ecs_task_definition" "backend" {
  family       = "${var.app_name}-${var.environment}-backend"
  network_mode = "bridge"

  container_definitions = <<EOF
[
  {
    "name": "${var.app_name}",
    "image": "${var.repository_url}/${var.app_name}:latest",
    "environment": [
      {
        "name": "PORT",
        "value": "80"
      }
    ],
    "cpu": 512,
    "memoryReservation": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ]
  }
]
EOF

  tags = {
    Application = "${var.app_name}"
    Environment = var.environment
    Name        = "${var.app_name}-${var.environment}-backend"
    Resource    = "modules.environment.aws_ecs_task_definition.backend"
  }
}

/**
* This role is automatically created by ECS the first time we try to use an ECS
* Cluster.  By the time we attempt to use it, it should exist.  However, there
* is a possible TECHDEBT race condition here.  I'm hoping terraform is smart
* enough to handle this - but I don't know that for a fact. By the time I tried
* to use it, it already existed.
*/
data "aws_iam_role" "ecs_service" {
  name = "AWSServiceRoleForECS"
}

/**
* Create the ECS Service that will wrap the task definition.  Used primarily to
* define the connections to the load balancer and the placement strategies and
* constraints on the tasks.
*/
resource "aws_ecs_service" "backend" {
  name            = "${var.app_name}-${var.environment}-backend"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.backend.arn

  iam_role = data.aws_iam_role.ecs_service.arn

  launch_type = "EC2"

  desired_count                      = 2
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 100
  load_balancer {
    container_name   = var.app_name
    container_port   = 80
    target_group_arn = aws_alb_target_group.fashion_flux_tg.arn
  }

  tags = {
    Application = "${var.app_name}"
    Environment = var.environment
    Resource    = "modules.environment.aws_ecs_service.backend"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_agent,
    aws_alb_listener.fashion_flux_listener
  ]
}

