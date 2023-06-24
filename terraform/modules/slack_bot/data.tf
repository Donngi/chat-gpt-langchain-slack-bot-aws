data "aws_ssm_parameter" "chat_gpt_api_key" {
  name = "/chat-gpt-langchain-slack-bot/open-ai-api-key"
}

data "aws_ssm_parameter" "bot_user_token" {
  name = "/chat-gpt-langchain-slack-bot/bot-user-token"
}

data "aws_ssm_parameter" "signing_secret" {
  name = "/chat-gpt-langchain-slack-bot/signing-secret"
}
