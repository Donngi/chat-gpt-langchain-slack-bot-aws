resource "aws_api_gateway_rest_api" "chat_gpt_langchain_slack_bot" {
  name = "chat-gpt-langchain-slack-bot"
}

resource "aws_api_gateway_resource" "slack" {
  parent_id = aws_api_gateway_rest_api.chat_gpt_langchain_slack_bot.root_resource_id
  path_part = "slack"

  rest_api_id = aws_api_gateway_rest_api.chat_gpt_langchain_slack_bot.id
}

resource "aws_api_gateway_method" "slack_post" {
  authorization = "NONE"

  http_method = "POST"
  resource_id = aws_api_gateway_resource.slack.id
  rest_api_id = aws_api_gateway_rest_api.chat_gpt_langchain_slack_bot.id
}

resource "aws_api_gateway_integration" "slack_post" {
  resource_id = aws_api_gateway_resource.slack.id
  rest_api_id = aws_api_gateway_rest_api.chat_gpt_langchain_slack_bot.id
  http_method = aws_api_gateway_method.slack_post.http_method

  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.gateway.invoke_arn
}

resource "aws_api_gateway_deployment" "chat_gpt_langchain_slack_bot" {
  rest_api_id = aws_api_gateway_rest_api.chat_gpt_langchain_slack_bot.id

  triggers = {
    redeployment = var.image_tag_gateway
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.slack_post,
    aws_api_gateway_integration.slack_post
  ]
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.chat_gpt_langchain_slack_bot.id
  rest_api_id   = aws_api_gateway_rest_api.chat_gpt_langchain_slack_bot.id
  stage_name    = "main"
}
