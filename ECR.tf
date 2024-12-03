
resource "aws_ecr_repository" "my_ecr_repo" {
  name                 = "my-private-repo"
  image_tag_mutability = "MUTABLE" # Optional: Can also be "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true # Enable automatic image scanning
  }

  encryption_configuration {
    encryption_type = "AES256" # Optional: Use KMS for custom keys
  }
}
