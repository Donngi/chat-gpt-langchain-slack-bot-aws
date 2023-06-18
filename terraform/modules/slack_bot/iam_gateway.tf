resource "aws_iam_role" "lambda_gateway" {
  name = "chat-gpt-slack-bot-lambda-gateway-role"

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

resource "aws_iam_role_policy_attachment" "lambda_gateway_basic_execution" {
  role       = aws_iam_role.lambda_gateway.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
