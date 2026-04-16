# Two public subnets (different AZs) for the internet-facing ALB. One private
# subnet for ECS tasks (Fargate) with egress through a single NAT gateway.
# AZs are fixed to us-east-1b / us-east-1c for this project.
#
# -----------------------------------------------------------------------------
# Locals (availability zones)
# -----------------------------------------------------------------------------
locals {
  az1 = "us-east-1b"
  az2 = "us-east-1c"
}

# -----------------------------------------------------------------------------
# Public subnets
# -----------------------------------------------------------------------------
# --- Public subnet (AZ: us-east-1b) ---
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.portfolio_cicd_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = local.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-az1"
  }
}

# --- Public subnet (AZ: us-east-1c) ---
resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.portfolio_cicd_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = local.az2
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-az2"
  }
}

# -----------------------------------------------------------------------------
# Private application subnet
# -----------------------------------------------------------------------------
resource "aws_subnet" "private_app_subnet_az1" {
  vpc_id            = aws_vpc.portfolio_cicd_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = local.az1

  tags = {
    Name = "private-app-subnet-az1"
  }
}
