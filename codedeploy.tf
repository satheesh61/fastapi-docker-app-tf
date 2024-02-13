resource "aws_codedeploy_app" "application_deploy_ec2" {
  name = var.codedeploy_name
}
resource "aws_codedeploy_deployment_group" "application_deploy_ec2_group" {
  app_name = aws_codedeploy_app.application_deploy_ec2.name
  deployment_group_name = var.codedeploy_groupname
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn = aws_iam_role.fastapi_demo_codedeploy_role.arn
  alarm_configuration {
    enabled = false
    ignore_poll_alarm_failure = false
  }
  deployment_style {
    deployment_type = "IN_PLACE"
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  }
  ec2_tag_set {
    ec2_tag_filter {
      key   = var.ec2_tag_key
      type  = "KEY_AND_VALUE"
      value = var.ec2_tag_value
    }
  }
  auto_rollback_configuration {
    enabled = false
    events = ["DEPLOYMENT_FAILURE"]
  }
}

resource "aws_iam_role" "fastapi_demo_codedeploy_role" {
  name = "fastapi-demo-codedeploy-role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess","arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.fastapi_demo_codedeploy_role.name
}


