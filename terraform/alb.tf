# -----------------------------------------------------------------------------
# Application Load Balancer
# -----------------------------------------------------------------------------
resource "aws_lb" "portfolio_cicd" {
  name               = "portfolio-cicd-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.portfolio_cicd_alb_sg.id]
  subnets            = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id]

  tags = {
    Name = "portfolio-cicd-alb"
  }
}

# -----------------------------------------------------------------------------
# Target group
# -----------------------------------------------------------------------------
resource "aws_lb_target_group" "portfolio_app" {
  name        = "portfolio-app-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.portfolio_cicd_vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "portfolio-app-tg"
  }
}

# -----------------------------------------------------------------------------
# Listener (HTTP to target group)
# -----------------------------------------------------------------------------
resource "aws_lb_listener" "portfolio_cicd_http" {
  load_balancer_arn = aws_lb.portfolio_cicd.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.portfolio_app.arn
  }
}
