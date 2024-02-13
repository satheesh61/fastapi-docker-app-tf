resource "aws_iam_role" "ec2-role" {
  name = "fastapi-demo-ec2-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "fastapi_demo_ec2_policy" {
  role = aws_iam_role.ec2-role.name

  policy = jsonencode(
    {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": [
      "${aws_s3_bucket.api_app_server_s3_01.arn}",
      "${aws_s3_bucket.api_app_server_s3_01.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
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
      ],
      "Resource": ["*"]
    }
  ]
})

}

resource "aws_iam_instance_profile" "fastapi_demo_instance_profile" {
  name = "fastapi-demo-instance-profile"
  role = aws_iam_role.ec2-role.name
}