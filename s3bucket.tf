resource "aws_s3_bucket" "api_app_server_s3_01" {
    bucket = var.s3_bucket_name
   # acl = "private"

}

resource "aws_s3_bucket_policy" "api_app_server_s3_01_s3_policy" {
  bucket = aws_s3_bucket.api_app_server_s3_01.id
  policy       = data.aws_iam_policy_document.api_app_server_s3_01_policy.json
}

data "aws_iam_policy_document" "api_app_server_s3_01_policy" {
  statement {
    sid = "AllowSSLRequestsOnly"

    principals {
      type = "*"
      identifiers = ["*"]
    }
    
    effect = "Deny"

    actions = ["s3:*"]

    resources = [
      "${aws_s3_bucket.api_app_server_s3_01.arn}",
      "${aws_s3_bucket.api_app_server_s3_01.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false"
        ]
    }
  }
}
