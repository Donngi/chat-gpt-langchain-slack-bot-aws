resource "aws_lambda_function" "chat_gpt_requester" {
  function_name = "chat-gpt-slack-bot-chat-gpt-requester"
  role          = aws_iam_role.lambda_chat_gpt_requester.arn

  package_type = "Image"
  image_uri    = "${aws_ecr_repository.lambda_chat_gpt_requester.repository_url}:${var.image_tag_chat_gpt_requester}"

  architectures = ["arm64"]

  timeout = 180
  publish = true

  environment {
    variables = {
      SSM_KEY_OPEN_AI_API_KEY            = data.aws_ssm_parameter.open_ai_api_key.name
      SSM_KEY_SLACK_BOT_USER_OAUTH_TOKEN = data.aws_ssm_parameter.bot_user_token.name
      LOG_LEVEL                          = "DEBUG"
    }
  }
}
