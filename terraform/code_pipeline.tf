data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# Source: GitHub via CodeStar Connections (complete connection in AWS Console first)
# -----------------------------------------------------------------------------
variable "codestar_connection_arn" {
  description = "ARN of the CodeStar Connections connection authorized for your Git provider."
  type        = string
}

variable "github_repository_id" {
  description = "Repository as owner/name (e.g. myorg/Cloud-CI-CD-Pipeline)."
  type        = string
}

variable "github_branch" {
  description = "Branch the pipeline watches for changes."
  type        = string
  default     = "main"
}

# -----------------------------------------------------------------------------
# Artifact store
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "${data.aws_caller_identity.current.account_id}-portfolio-cicd-pipeline-artifacts"

  tags = {
    Name = "portfolio-cicd-pipeline-artifacts"
  }
}

resource "aws_s3_bucket_public_access_block" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# -----------------------------------------------------------------------------
# CodePipeline
# -----------------------------------------------------------------------------
resource "aws_codepipeline" "portfolio_app" {
  name     = "portfolio-app-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = var.github_repository_id
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.portfolio_app.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = aws_ecs_cluster.portfolio_cicd_cluster.name
        ServiceName = aws_ecs_service.portfolio_app.name
        FileName    = "imagedefinitions.json"
      }
    }
  }

  tags = {
    Name = "portfolio-app-pipeline"
  }
}
