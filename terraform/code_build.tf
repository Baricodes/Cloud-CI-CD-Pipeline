# CodeBuild project for the pipeline Build stage. Uses CODEPIPELINE source
# and artifacts; buildspec at repo root (buildspec.yml). privileged_mode is
# required for docker build/push. No logs_config block: CodeBuild sends logs to
# CloudWatch under /aws/codebuild/<project-name> by default (see IAM in iam.tf).
#
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

  tags = {
    Name = "portfolio-app-build"
  }
}
