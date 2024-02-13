resource "aws_codestarconnections_connection" "githubconnection" {
  name = var.codestarconnection_name
  provider_type = "GitHub"
}

