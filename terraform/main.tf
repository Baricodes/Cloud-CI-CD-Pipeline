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

resource "aws_ecr_repository" "website_image_repo" {
  name                 = "website-image-repo"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecs_cluster" "website_ecs_cluster" {
  name = "website-ecs-cluster"
}
