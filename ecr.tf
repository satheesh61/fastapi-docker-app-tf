resource "aws_ecr_repository" "backend_repo" {
  name                 = var.backend_ecr_repo
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
