moved {
  from = aws_vpc.webapp_vpc
  to   = aws_vpc.portfolio_cicd_vpc
}

moved {
  from = aws_internet_gateway.webapp_igw
  to   = aws_internet_gateway.portfolio_cicd_igw
}

moved {
  from = aws_subnet.public_subnet_a
  to   = aws_subnet.public_subnet_az1
}

moved {
  from = aws_subnet.private_app_a
  to   = aws_subnet.private_app_subnet_az1
}

moved {
  from = aws_route_table.public_rt
  to   = aws_route_table.portfolio_cicd_public_rt
}

moved {
  from = aws_route.public_internet
  to   = aws_route.portfolio_cicd_public_internet
}

moved {
  from = aws_route_table_association.public_subnet_a
  to   = aws_route_table_association.public_subnet_az1
}

moved {
  from = aws_route_table.private_app_a_rt
  to   = aws_route_table.private_app_subnet_az1_rt
}

moved {
  from = aws_route.private_app_a_internet
  to   = aws_route.private_app_subnet_az1_internet
}

moved {
  from = aws_route_table_association.private_app_a
  to   = aws_route_table_association.private_app_subnet_az1
}

moved {
  from = aws_eip.nat_a
  to   = aws_eip.nat_gateway_az1
}

moved {
  from = aws_nat_gateway.nat_a
  to   = aws_nat_gateway.nat_gateway_az1
}

moved {
  from = aws_security_group.alb_sg
  to   = aws_security_group.portfolio_cicd_alb_sg
}

moved {
  from = aws_security_group.app_sg
  to   = aws_security_group.portfolio_cicd_app_sg
}

moved {
  from = aws_ecr_repository.website_image_repo
  to   = aws_ecr_repository.portfolio_app
}

moved {
  from = aws_ecs_cluster.website_ecs_cluster
  to   = aws_ecs_cluster.portfolio_cicd_cluster
}
