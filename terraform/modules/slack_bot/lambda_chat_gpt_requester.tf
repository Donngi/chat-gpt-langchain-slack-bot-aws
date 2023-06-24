resource "aws_lambda_function" "chat_gpt_requester" {
  function_name = "chat-gpt-slack-bot-chat-gpt-requester"
  role          = aws_iam_role.lambda_chat_gpt_requester.arn

  package_type = "Image"
  image_uri    = "${aws_ecr_repository.lambda_chat_gpt_requester.repository_url}:${var.image_tag_chat_gpt_requester}"

  architectures = ["arm64"]

  timeout = 180
  publish = true
}
