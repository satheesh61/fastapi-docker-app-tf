resource "aws_codepipeline" "api_app_cp_01" {
    name  = "${var.project_name}-cp-01"
	role_arn = aws_iam_role.fastapi_demo_codepipeline_role.arn
    tags = var.tags
	
    artifact_store {
    location = aws_s3_bucket.api_app_server_s3_01.id
    type     = "S3"
    }
    stage{
       name = "Source"
       action {
        name = "Source"
        category = "Source"
        owner = "AWS"
        configuration = {
            BranchName = "main"
            ConnectionArn = aws_codestarconnections_connection.githubconnection.arn
            FullRepositoryId = var.githubrepo_name
            OutputArtifactFormat = "CODE_ZIP"
			DetectChanges = "true"
        }
        provider = "CodeStarSourceConnection"
        version = "1"
        output_artifacts = ["SourceArtifact"]
        #run_order = 1
        }
    }

    stage {
      name = "Build"
      action {
        name = "API-Build"
        category = "Build"
        owner = "AWS"
        configuration = {
            BatchEnabled = "false"
            ProjectName = aws_codebuild_project.apibuildproject.name
        }
        input_artifacts = ["SourceArtifact"]
        provider = "CodeBuild"
        version = "1"
        output_artifacts = ["BuildArtifact"]
        #run_order = 1
      }
    }
    stage {
      name = "Deploy"
      action {
        name = "Deploy"
        category = "Deploy"
        owner = "AWS"
        provider = "CodeDeploy"
        input_artifacts = ["BuildArtifact"]
        version = "1"
        configuration = {
            ApplicationName = aws_codedeploy_app.application_deploy_ec2.name
            DeploymentGroupName = aws_codedeploy_deployment_group.application_deploy_ec2_group.deployment_group_name
        }
      }
    }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "fastapi_demo_codepipeline_role" {
  name               = "fastapi-demo-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.fastapi_demo_codepipeline_role.id
  policy = jsonencode(
 {
	"Version": "2012-10-17",
	"Statement": [
        {
			"Action": [
				"iam:PassRole"
			],
			"Resource": "*",
			"Effect": "Allow",
			"Condition": {
				"StringEqualsIfExists": {
					"iam:PassedToService": [
						"cloudformation.amazonaws.com",
						"elasticbeanstalk.amazonaws.com",
						"ec2.amazonaws.com",
						"ecs-tasks.amazonaws.com"
					]
				}
			}
		},
		{
			"Action": [
				"codecommit:CancelUploadArchive",
				"codecommit:GetBranch",
				"codecommit:GetCommit",
				"codecommit:GetRepository",
				"codecommit:GetUploadArchiveStatus",
				"codecommit:UploadArchive"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"codedeploy:CreateDeployment",
				"codedeploy:GetApplication",
				"codedeploy:GetApplicationRevision",
				"codedeploy:GetDeployment",
				"codedeploy:GetDeploymentConfig",
				"codedeploy:RegisterApplicationRevision"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"codestar-connections:UseConnection"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"elasticbeanstalk:*",
				"ec2:*",
				"elasticloadbalancing:*",
				"autoscaling:*",
				"cloudwatch:*",
				"s3:*",
				"sns:*",
				"cloudformation:*",
				"rds:*",
				"sqs:*",
				"ecs:*"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"lambda:InvokeFunction",
				"lambda:ListFunctions"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"opsworks:CreateDeployment",
				"opsworks:DescribeApps",
				"opsworks:DescribeCommands",
				"opsworks:DescribeDeployments",
				"opsworks:DescribeInstances",
				"opsworks:DescribeStacks",
				"opsworks:UpdateApp",
				"opsworks:UpdateStack"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"cloudformation:CreateStack",
				"cloudformation:DeleteStack",
				"cloudformation:DescribeStacks",
				"cloudformation:UpdateStack",
				"cloudformation:CreateChangeSet",
				"cloudformation:DeleteChangeSet",
				"cloudformation:DescribeChangeSet",
				"cloudformation:ExecuteChangeSet",
				"cloudformation:SetStackPolicy",
				"cloudformation:ValidateTemplate"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"codebuild:BatchGetBuilds",
				"codebuild:StartBuild",
				"codebuild:BatchGetBuildBatches",
				"codebuild:StartBuildBatch"
			],
			"Resource": "*",
			"Effect": "Allow"
		},
		{
			"Effect": "Allow",
			"Action": [
				"devicefarm:ListProjects",
				"devicefarm:ListDevicePools",
				"devicefarm:GetRun",
				"devicefarm:GetUpload",
				"devicefarm:CreateUpload",
				"devicefarm:ScheduleRun"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"servicecatalog:ListProvisioningArtifacts",
				"servicecatalog:CreateProvisioningArtifact",
				"servicecatalog:DescribeProvisioningArtifact",
				"servicecatalog:DeleteProvisioningArtifact",
				"servicecatalog:UpdateProduct"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"cloudformation:ValidateTemplate"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ecr:DescribeImages"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"states:DescribeExecution",
				"states:DescribeStateMachine",
				"states:StartExecution"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"appconfig:StartDeployment",
				"appconfig:StopDeployment",
				"appconfig:GetDeployment"
			],
			"Resource": "*"
		}
	]
})
}