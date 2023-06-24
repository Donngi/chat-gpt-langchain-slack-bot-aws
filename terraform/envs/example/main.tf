module "slack_bot" {
  source = "../../modules/slack_bot"

  image_tag_chat_gpt_requester = "v1"
  image_tag_gateway            = "v5"
}
