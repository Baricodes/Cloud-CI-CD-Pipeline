# Public subnets: default route to the internet gateway. Private app subnet:
# default route to the NAT gateway (ECS pulls images, etc.).
#
# -----------------------------------------------------------------------------
# Public route table & associations
# -----------------------------------------------------------------------------
resource "aws_route_table" "portfolio_cicd_public_rt" {
  vpc_id = aws_vpc.portfolio_cicd_vpc.id

  tags = {
    Name = "portfolio-cicd-public-rt"
  }
}

# --- Default route: public subnets → internet gateway ---
resource "aws_route" "portfolio_cicd_public_internet" {
  route_table_id         = aws_route_table.portfolio_cicd_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.portfolio_cicd_igw.id
}

# --- Attach public route table to each public subnet ---
resource "aws_route_table_association" "public_subnet_az1" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.portfolio_cicd_public_rt.id
}

resource "aws_route_table_association" "public_subnet_az2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.portfolio_cicd_public_rt.id
}

# -----------------------------------------------------------------------------
# Private application route table & association
# -----------------------------------------------------------------------------
resource "aws_route_table" "private_app_subnet_az1_rt" {
  vpc_id = aws_vpc.portfolio_cicd_vpc.id

  tags = {
    Name = "portfolio-cicd-private-app-rt-az1"
  }
}

# --- Default route: private app subnet → NAT gateway ---
resource "aws_route" "private_app_subnet_az1_internet" {
  route_table_id         = aws_route_table.private_app_subnet_az1_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_az1.id
}

# --- Attach private app route table to the private subnet ---
resource "aws_route_table_association" "private_app_subnet_az1" {
  subnet_id      = aws_subnet.private_app_subnet_az1.id
  route_table_id = aws_route_table.private_app_subnet_az1_rt.id
}
