resource "aws_ecr_repository" "lambda_chat_gpt_requester" {
  name                 = "lambda-slack-bot-chat-gpt-requester"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
