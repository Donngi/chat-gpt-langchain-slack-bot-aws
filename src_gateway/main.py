import logging
import os
from logging import Logger
from typing import Any, Dict, cast

import boto3
from slack_bolt import App
from slack_bolt.adapter.aws_lambda import SlackRequestHandler
from slack_bolt.context.say import Say

ssm = boto3.client("ssm")

ssm_key_signing_secret = os.environ.get("SSM_KEY_SLACK_SIGNING_SECRET")
if ssm_key_signing_secret is None:
    raise Exception("SSM_KEY_SLACK_SIGNING_SECRET environment variable not set")
signing_secret =  ssm.get_parameter(Name=ssm_key_signing_secret, WithDecryption=True) \
                    ["Parameter"]["Value"]

ssm_key_bot_user_token = os.environ.get("SSM_KEY_SLACK_BOT_USER_OAUTH_TOKEN")
if ssm_key_bot_user_token is None:
    raise Exception("SSM_KEY_SLACK_BOT_USER_OAUTH_TOKEN environment variable not set")
bot_user_token =  ssm.get_parameter(Name=ssm_key_bot_user_token, WithDecryption=True) \
                    ["Parameter"]["Value"]

app = App(process_before_response=True, token=bot_user_token,signing_secret=signing_secret)
print(app)
SlackRequestHandler.clear_all_log_handlers()
logging.basicConfig(format="%(asctime)s %(message)s", level=logging.DEBUG)

@app.event("app_mention") # type: ignore
def handle_app_mentions(body: Dict[str, Any], say: Say, logger: Logger) -> None:
    """
    Handle app mentions
    
    You can find all the arguments and their respective types 
    that can be used in the listener at this link:
    https://github.com/slackapi/bolt-python/blob/3e5f012767d37eaa01fb0ea55bd6ae364ecf320b/slack_bolt/kwargs_injection/args.py
    """
    logger.info("Hello!!!")
    logger.info(body)
    say("What's up?")

def handler(event: Dict[str, Any] , context: Dict[str,Any]) -> Dict[str, Any]:
    print(event)
    slack_handler=SlackRequestHandler(app=app)
    return cast(Dict[str, Any], slack_handler.handle(event,context)) 
