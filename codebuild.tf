resource "aws_codebuild_project" "apibuildproject" {
    name = var.apicodebuild_name
    description = "API Code Build"
    service_role = aws_iam_role.fastapi_demo_codebuild_role.arn
    build_timeout = "60"
    source {
      buildspec = "buildspec-api.yaml"
      insecure_ssl = false
      type = "CODEPIPELINE"
    }
    artifacts {
      type = "CODEPIPELINE"
      packaging = "NONE"
      name = var.apicodebuild_name
      encryption_disabled = false
    }
    cache {
      type = "NO_CACHE"
    }
    environment {
      compute_type = "BUILD_GENERAL1_SMALL"
      image = "aws/codebuild/standard:5.0"
      image_pull_credentials_type = "CODEBUILD"
      privileged_mode = true
      type = "LINUX_CONTAINER"
      environment_variable{
        name = "ecr_api_repo_url"
        value = aws_ecr_repository.backend_repo.repository_url
        type = "PLAINTEXT"
     }
     environment_variable {
       name = "ecr_repo_name"
       value = aws_ecr_repository.backend_repo.name
       type = "PLAINTEXT"
     }
    }
    
    badge_enabled = false
    logs_config {
      cloudwatch_logs {
        status = "ENABLED"
      }
    }

}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "fastapi_demo_codebuild_role" {
  name               = "fastapi-demo-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

data "aws_iam_policy_document" "codebuild_base_policy" {
    statement {
      effect = "Allow"
  
      actions = [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents",
      ]
  
      resources = ["*"]
    }

    statement  {
      effect = "Allow"
      resources = ["*"]
      actions = [
       "s3:PutObject",
       "s3:GetObject",
       "s3:GetObjectVersion",
       "s3:GetBucketAcl",
       "s3:GetBucketLocation"
      ]
     }
    statement  {
      effect = "Allow"
      resources = ["*"]
      actions = [
       "codebuild:CreateReportGroup",
       "codebuild:CreateReport",
       "codebuild:UpdateReport",
       "codebuild:BatchPutTestCases",
       "codebuild:BatchPutCodeCoverages"
      ]
    }
    statement  {
      effect = "Allow"
      resources = ["*"]
      actions = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "ecr:GetLifecyclePolicy",
        "ecr:GetLifecyclePolicyPreview",
        "ecr:ListTagsForResource",
        "ecr:DescribeImageScanFindings",
        "ecr:CompleteLayerUpload",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart",
        "sts:GetServiceBearerToken"
      ]
    }  
}

resource "aws_iam_role_policy" "codebuild_policy" {
    role = aws_iam_role.fastapi_demo_codebuild_role.name
    policy = data.aws_iam_policy_document.codebuild_base_policy.json
}