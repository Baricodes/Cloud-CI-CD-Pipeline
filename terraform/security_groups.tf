# ALB: HTTP (and HTTPS ingress for a future ACM listener; only HTTP is wired
# in alb.tf today). App tier: accepts HTTP only from the ALB security group.
#
# -----------------------------------------------------------------------------
# Security group: ALB
# -----------------------------------------------------------------------------
resource "aws_security_group" "portfolio_cicd_alb_sg" {
  name        = "portfolio-cicd-alb-sg"
  description = "Security group for application load balancer"
  vpc_id      = aws_vpc.portfolio_cicd_vpc.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "portfolio-cicd-alb-sg"
  }
}

# -----------------------------------------------------------------------------
# Security group: application tier (ECS)
# -----------------------------------------------------------------------------
resource "aws_security_group" "portfolio_cicd_app_sg" {
  name        = "portfolio-cicd-app-sg"
  description = "Security group for application tier"
  vpc_id      = aws_vpc.portfolio_cicd_vpc.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.portfolio_cicd_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "portfolio-cicd-app-sg"
  }
}
