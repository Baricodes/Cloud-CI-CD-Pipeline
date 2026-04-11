# -----------------------------------------------------------------------------
# CodeBuild: pipeline build stage (IAM: iam.tf; artifact bucket: code_pipeline.tf)
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# CloudWatch Logs (CodeBuild)
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "codebuild_portfolio_app" {
  name              = "/aws/codebuild/portfolio-app-build"
  retention_in_days = 14
}

# -----------------------------------------------------------------------------
# CodeBuild project
# -----------------------------------------------------------------------------
resource "aws_codebuild_project" "portfolio_app" {
  name          = "portfolio-app-build"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 60

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild_portfolio_app.name
      stream_name = "build-log"
    }
  }

  depends_on = [aws_cloudwatch_log_group.codebuild_portfolio_app]

  tags = {
    Name = "portfolio-app-build"
  }
}
