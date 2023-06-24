init:
	poetry install

build-image:
	poetry export -f requirements.txt --output requirements.txt
	docker build -t lambda-chat-gpt-slack-bot-chat-gpt-requester . 

lint:
	poetry run ruff *.py
