# Values to use after apply: load balancer URL, ECS/ECR identifiers, pipeline
# names, and core network id. Grouped by concern for quick scanning.
#
# -----------------------------------------------------------------------------
# Application entry (ALB)
# -----------------------------------------------------------------------------
output "application_url" {
  description = "HTTP URL for the site (ALB DNS name, port 80)."
  value       = "http://${aws_lb.portfolio_cicd.dns_name}/"
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.portfolio_cicd.dns_name
}

# -----------------------------------------------------------------------------
# Container platform (ECR & ECS)
# -----------------------------------------------------------------------------
output "ecr_repository_url" {
  description = "ECR repository URL for docker push/pull."
  value       = aws_ecr_repository.portfolio_app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster hosting the service."
  value       = aws_ecs_cluster.portfolio_cicd_cluster.name
}

output "ecs_service_name" {
  description = "ECS service updated by the pipeline deploy stage."
  value       = aws_ecs_service.portfolio_app.name
}

# -----------------------------------------------------------------------------
# CI/CD (CodePipeline & build)
# -----------------------------------------------------------------------------
output "codepipeline_name" {
  description = "CodePipeline name."
  value       = aws_codepipeline.portfolio_app.name
}

output "codebuild_project_name" {
  description = "CodeBuild project used by the pipeline build stage."
  value       = aws_codebuild_project.portfolio_app.name
}

output "pipeline_artifacts_bucket" {
  description = "S3 bucket storing CodePipeline stage artifacts."
  value       = aws_s3_bucket.pipeline_artifacts.bucket
}

# -----------------------------------------------------------------------------
# Network
# -----------------------------------------------------------------------------
output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.portfolio_cicd_vpc.id
}
