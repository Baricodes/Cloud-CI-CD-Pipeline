terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "portfolio_app" {
  name                 = "portfolio-app"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecs_cluster" "portfolio_cicd_cluster" {
  name = "portfolio-cicd-cluster"
}
