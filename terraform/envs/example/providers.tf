provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      repo = "chat-gpt-langchain-slack-bot-aws"
    }
  }
}
