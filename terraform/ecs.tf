# ECR repository, Fargate cluster/service, task definition, and ECS CloudWatch
# log group. Container name "app" must match buildspec imagedefinitions.json
# and the CodePipeline ECS deploy action. Pipeline image updates: Terraform
# ignores task_definition on the service so applies do not revert deploys.
#
# -----------------------------------------------------------------------------
# ECR
# -----------------------------------------------------------------------------
resource "aws_ecr_repository" "portfolio_app" {
  name                 = "portfolio-app"
  image_tag_mutability = "MUTABLE"
}

# -----------------------------------------------------------------------------
# ECS cluster
# -----------------------------------------------------------------------------
resource "aws_ecs_cluster" "portfolio_cicd_cluster" {
  name = "portfolio-cicd-cluster"
}

# Log group for the task awslogs driver (see container logConfiguration).
#
# -----------------------------------------------------------------------------
# CloudWatch Logs (ECS)
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "portfolio_app_logs" {
  name = "/ecs/portfolio-app"
}

# -----------------------------------------------------------------------------
# Task definition
# -----------------------------------------------------------------------------
resource "aws_ecs_task_definition" "portfolio_app" {
  family                   = "portfolio-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${aws_ecr_repository.portfolio_app.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.portfolio_app_logs.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# -----------------------------------------------------------------------------
# ECS service
# -----------------------------------------------------------------------------
resource "aws_ecs_service" "portfolio_app" {
  name            = "portfolio-app"
  cluster         = aws_ecs_cluster.portfolio_cicd_cluster.id
  task_definition = aws_ecs_task_definition.portfolio_app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # --- Register tasks with the ALB target group ---
  load_balancer {
    target_group_arn = aws_lb_target_group.portfolio_app.arn
    container_name   = "app"
    container_port   = 80
  }

  # --- Tasks run in private subnets (egress via NAT) ---
  network_configuration {
    subnets          = [aws_subnet.private_app_subnet_az1.id]
    security_groups  = [aws_security_group.portfolio_cicd_app_sg.id]
    assign_public_ip = false
  }

  depends_on = [aws_lb_listener.portfolio_cicd_http]

  # --- Pipeline updates task definition; Terraform does not revert deploys ---
  lifecycle {
    ignore_changes = [task_definition]
  }
}
