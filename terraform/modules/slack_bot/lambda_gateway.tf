resource "aws_lambda_function" "gateway" {
  function_name = "chat-gpt-slack-bot-gateway"
  role          = aws_iam_role.lambda_gateway.arn

  package_type = "Image"
  image_uri    = "${aws_ecr_repository.lambda_gateway.repository_url}:${var.image_tag_gateway}"

  architectures = ["arm64"]

  timeout = 29
  publish = true

  environment {
    variables = {
      SSM_KEY_SLACK_SIGNING_SECRET       = data.aws_ssm_parameter.signing_secret.name
      SSM_KEY_SLACK_BOT_USER_OAUTH_TOKEN = data.aws_ssm_parameter.bot_user_token.name
      CHAT_GPT_LAMBDA_ARN                = aws_lambda_function.chat_gpt_requester.arn
    }
  }
}

resource "aws_lambda_permission" "gateway" {
  statement_id  = "AllowInvokeByAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.gateway.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.chat_gpt_langchain_slack_bot.execution_arn}/*"
}
