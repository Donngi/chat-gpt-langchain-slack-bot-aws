resource "aws_ecr_repository" "lambda_gateway" {
  name                 = "lambda-slack-bot-gateway"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
