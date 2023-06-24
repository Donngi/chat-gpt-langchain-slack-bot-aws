import json
import logging
import os
from logging import Logger
from typing import Any, Dict, cast

import boto3
from slack_bolt import App, BoltContext
from slack_bolt.adapter.aws_lambda import SlackRequestHandler
from slack_bolt.context.say import Say
from slack_sdk import WebClient

ssm_client = boto3.client("ssm")

ssm_key_signing_secret = os.environ.get("SSM_KEY_SLACK_SIGNING_SECRET")
if ssm_key_signing_secret is None:
    raise Exception("SSM_KEY_SLACK_SIGNING_SECRET environment variable not set")
signing_secret = ssm_client.get_parameter(
    Name=ssm_key_signing_secret, WithDecryption=True
)["Parameter"]["Value"]

ssm_key_bot_user_token = os.environ.get("SSM_KEY_SLACK_BOT_USER_OAUTH_TOKEN")
if ssm_key_bot_user_token is None:
    raise Exception("SSM_KEY_SLACK_BOT_USER_OAUTH_TOKEN environment variable not set")
bot_user_token = ssm_client.get_parameter(
    Name=ssm_key_bot_user_token, WithDecryption=True
)["Parameter"]["Value"]

app = App(
    process_before_response=True, token=bot_user_token, signing_secret=signing_secret
)

chat_gpt_requester_lambda_arn = os.environ["CHAT_GPT_REQUESTER_LAMBDA_ARN"]

SlackRequestHandler.clear_all_log_handlers()
logging.basicConfig(
    format="%(levelname)s: %(message)s", level=os.getenv("LOG_LEVEL", logging.INFO)
)


@app.event("app_mention")  # type: ignore
def handle_app_mentions(
    body: Dict[str, Any],
    client: WebClient,
    say: Say,
    logger: Logger,
    context: BoltContext,
) -> None:
    """
    Handle app mentions. Send user messages to Lambda function that calls ChatGPT API.

    We have to return response to Slack within 3 seconds.
    However ChatGPT API sometimes take more than 3 seconds.
    Therefore, we send the quick response as soon as a message is received,
    and send ChatGPT response async by using another Lambda function.

    You can find all the arguments and their respective types
    that can be used in the slack bolt's listener at this link:
    https://github.com/slackapi/bolt-python/blob/3e5f012767d37eaa01fb0ea55bd6ae364ecf320b/slack_bolt/kwargs_injection/args.py
    """
    logger.debug(body)

    try:
        event = body["event"]
        thread_ts = event.get("thread_ts") if event.get("thread_ts") else event["ts"]

        wait_message = "Wait a moment, I'm thinking ..."
        res_say = say(
            {
                "text": wait_message,
                "thread_ts": thread_ts,
            }
        )
        logger.debug(f"res_say:{res_say}")

        replies = client.conversations_replies(channel=event["channel"], ts=thread_ts)
        thread_messages = [
            message
            for message in replies["messages"]
            if message["text"] != wait_message
        ]
        logger.debug(f"thread_messages:{thread_messages}")

        bot_user_id = client.auth_test()["user_id"]
        structed_messages = [
            {
                "role": "ai" if message["user"] == bot_user_id else "human",
                "content": message["text"].replace(f"<@{bot_user_id}>", ""),
            }
            for message in thread_messages
        ]
        logger.debug(f"structed_messages:{structed_messages}")

        lambda_client = boto3.client("lambda")
        res_invoke = lambda_client.invoke(
            FunctionName=chat_gpt_requester_lambda_arn,
            Payload=json.dumps(structed_messages),
            InvocationType="Event",
        )
        logger.debug(f"res_invoke:{res_invoke}")
        if res_invoke["StatusCode"] != 202:
            raise Exception(f"Failed to invoke lambda: {res_invoke}")

    except Exception as e:
        logger.error(e)
        say(
            {
                "text": "Sorry, something went wrong ...",
                "thread_ts": thread_ts,
            }
        )


def handler(event: Dict[str, Any], context: Dict[str, Any]) -> Dict[str, Any]:
    slack_handler = SlackRequestHandler(app=app)
    return cast(Dict[str, Any], slack_handler.handle(event, context))
