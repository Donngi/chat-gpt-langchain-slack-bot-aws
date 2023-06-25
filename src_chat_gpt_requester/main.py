import logging
import os
from typing import Any, Callable, Dict, TypedDict

import boto3
from langchain.chat_models import ChatOpenAI
from langchain.schema import AIMessage, BaseMessage, HumanMessage, SystemMessage
from slack_sdk import WebClient

logging.basicConfig(
    format="%(levelname)s: %(message)s", level=os.getenv("LOG_LEVEL", logging.INFO)
)
logger = logging.getLogger(__name__)

ssm_client = boto3.client("ssm")

ssm_key_open_ai_api_key = os.environ.get("SSM_KEY_OPEN_AI_API_KEY")
if ssm_key_open_ai_api_key is None:
    raise Exception("SSM_KEY_OPEN_AI_API_KEY environment variable not set")
open_ai_api_key = ssm_client.get_parameter(
    Name=ssm_key_open_ai_api_key, WithDecryption=True
)["Parameter"]["Value"]

ssm_key_bot_user_token = os.environ.get("SSM_KEY_SLACK_BOT_USER_OAUTH_TOKEN")
if ssm_key_bot_user_token is None:
    raise Exception("SSM_KEY_SLACK_BOT_USER_OAUTH_TOKEN environment variable not set")
bot_user_token = ssm_client.get_parameter(
    Name=ssm_key_bot_user_token, WithDecryption=True
)["Parameter"]["Value"]

MessageTypeDef = TypedDict(
    "MessageTypeDef",
    {
        "role": str,
        "content": str,
    },
)

EventTypeDef = TypedDict(
    "EventTypeDef",
    {
        "thread_ts": str,
        "thread_messages": list[MessageTypeDef],
        "channel": str,
        "wait_a_moment_ts": str,
    },
)


def get_update_wait_a_moment_message(
    client: WebClient, channel: str, ts: str
) -> Callable[[str], None]:
    def update_wait_a_moment_message(text: str) -> None:
        client.chat_update(
            channel=channel,
            ts=ts,
            text=text,
        )

    return update_wait_a_moment_message


def get_prompt_messages(unfiltered_messages: list[MessageTypeDef]) -> list[BaseMessage]:
    """
    Get the messages to be used as the prompt for the GPT.

    1. Convert the messages from the thread into a list of BaseMessage objects.
    2. Remove wait a moment message.
    3. Add a system message to the beginning of the list.
    """
    messages = [
        SystemMessage(content="You are a nice assistant."),
    ]
    for message in unfiltered_messages:
        if message["role"] == "ai":
            messages.append(AIMessage(content=message["content"]))
        elif message["role"] == "human":
            messages.append(HumanMessage(content=message["content"]))
        else:
            logger.error(f"Unknown role: {message['role']}")
    return messages


def handler(event: EventTypeDef, context: Dict[str, Any]) -> None:
    logger.debug(f"event: {event}")

    slack_client = WebClient(token=bot_user_token)
    update_wait_a_moment_message = get_update_wait_a_moment_message(
        client=slack_client, channel=event["channel"], ts=event["wait_a_moment_ts"]
    )

    try:
        messages = get_prompt_messages(event["thread_messages"])
        chat = ChatOpenAI(
            model_name="gpt-3.5-turbo-16k", openai_api_key=open_ai_api_key
        )
        res_chat_gpt = chat.predict_messages(messages=messages)
        logger.debug(f"res_chat_gpt: {res_chat_gpt}")

        update_wait_a_moment_message(res_chat_gpt.content)
    except Exception as e:
        logger.error(e)
        update_wait_a_moment_message("Sorry something went wrong.")
