from logging import Logger
from typing import Any, Dict, cast

from slack_bolt import App
from slack_bolt.adapter.aws_lambda import SlackRequestHandler
from slack_bolt.context.say import Say

app = App(process_before_response=True)

@app.event("app_mention") # type: ignore
def handle_app_mentions(body: Dict[str, Any], say: Say, logger: Logger) -> None:
    """
    Handle app mentions
    
    You can find all the arguments and their respective types 
    that can be used in the listener at this link:
    https://github.com/slackapi/bolt-python/blob/3e5f012767d37eaa01fb0ea55bd6ae364ecf320b/slack_bolt/kwargs_injection/args.py
    """
    logger.info(body)
    say("What's up?")

def handler(event: Dict[str, Any] , context: Dict[str,Any]) -> Dict[str, Any]:
    slack_handler=SlackRequestHandler(app=app)
    return cast(Dict[str, Any], slack_handler.handle(event=event,context=context) ) 
