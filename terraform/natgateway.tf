# -----------------------------------------------------------------------------
# Elastic IP (NAT)
# -----------------------------------------------------------------------------
resource "aws_eip" "nat_gateway_az1" {
  domain = "vpc"

  tags = {
    Name = "portfolio-cicd-nat-az1-eip"
  }

  depends_on = [aws_internet_gateway.portfolio_cicd_igw]
}

# -----------------------------------------------------------------------------
# NAT gateway
# -----------------------------------------------------------------------------
resource "aws_nat_gateway" "nat_gateway_az1" {
  allocation_id = aws_eip.nat_gateway_az1.id
  subnet_id     = aws_subnet.public_subnet_az1.id

  tags = {
    Name = "portfolio-cicd-nat-az1"
  }

  depends_on = [aws_internet_gateway.portfolio_cicd_igw]
}
