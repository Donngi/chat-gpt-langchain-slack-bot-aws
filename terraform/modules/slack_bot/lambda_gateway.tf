resource "aws_lambda_function" "gateway" {
  function_name = "chat-gpt-slack-bot-gateway"
  role          = aws_iam_role.lambda_gateway.arn

  package_type = "Image"
  image_uri    = "${aws_ecr_repository.lambda_gateway.repository_url}:latest"

  architectures = ["arm64"]

  timeout = 180
  publish = true
}
