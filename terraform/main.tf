# Root Terraform configuration for this repo. Companion .tf files in this
# directory define networking (VPC–ALB), ECS/ECR, IAM, CodePipeline/CodeBuild,
# and the pipeline artifact bucket. Region is us-east-1 throughout.
#
# -----------------------------------------------------------------------------
# Terraform & providers
# -----------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# -----------------------------------------------------------------------------
# AWS provider
# -----------------------------------------------------------------------------
provider "aws" {
  region = "us-east-1"
}
