from typing import Any, Dict, cast

from slack_bolt import App
from slack_bolt.adapter.aws_lambda import SlackRequestHandler

app = App(process_before_response=True)

def handler(event: Dict[str, Any] , context: Dict[str,Any]) -> Dict[str, Any]:
    slack_handler=SlackRequestHandler(app=app)
    return cast(Dict[str, Any], slack_handler.handle(event=event,context=context) ) 