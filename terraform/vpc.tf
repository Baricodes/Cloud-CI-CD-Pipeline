# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------
resource "aws_vpc" "portfolio_cicd_vpc" {
  cidr_block                       = "10.0.0.0/16"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = "portfolio-cicd-vpc"
  }
}

# -----------------------------------------------------------------------------
# Internet gateway
# -----------------------------------------------------------------------------
resource "aws_internet_gateway" "portfolio_cicd_igw" {
  vpc_id = aws_vpc.portfolio_cicd_vpc.id

  tags = {
    Name = "portfolio-cicd-igw"
  }
}
