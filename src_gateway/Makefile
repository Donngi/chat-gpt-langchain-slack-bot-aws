init:
	poetry install

build-image:
	poetry export -f requirements.txt --output requirements.txt
	docker build -t lambda-chat-gpt-slack-bot-gateway . 

lint:
	poetry run ruff *.py
	