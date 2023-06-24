resource "aws_ecr_repository" "lambda_gateway" {
  name                 = "lambda-chat-gpt-slack-bot-gateway"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
