resource "aws_iam_role" "lambda_chat_gpt_requester" {
  name = "chat-gpt-slack-bot-lambda-chat-gpt-requester-role"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Effect" : "Allow",
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_chat_gpt_requester_basic_execution" {
  role       = aws_iam_role.lambda_chat_gpt_requester.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_chat_gpt_requester_custom" {
  name = "${aws_iam_role.lambda_chat_gpt_requester.name}-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameter",
        ],
        "Resource" : [
          data.aws_ssm_parameter.bot_user_token.arn,
          data.aws_ssm_parameter.open_ai_api_key.arn,
        ],
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_chat_gpt_requester_custom" {
  role       = aws_iam_role.lambda_chat_gpt_requester.name
  policy_arn = aws_iam_policy.lambda_chat_gpt_requester_custom.arn
}
