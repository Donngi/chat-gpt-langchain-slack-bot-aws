### Terraform
terraform-apply-only-ecr:
	cd terraform/envs/example && \
	terraform apply \
	-target module.slack_bot.aws_ecr_repository.lambda_gateway \
	-target module.slack_bot.aws_ecr_repository.lambda_chat_gpt_requester

terraform-init:
	cd terraform/envs/example && \
	terraform init

terraform-apply:
	cd terraform/envs/example && \
	terraform apply

### Build images
push-images: push-image-chat-gpt-requester push-image-gateway

push-image-chat-gpt-requester:
	set -a && source .env && set +a && \
	cd src_chat_gpt_requester && \
	make build-image && \
	aws ecr get-login-password --region $${ECR_AWS_REGION} | docker login --username AWS --password-stdin $${ECR_AWS_ACCOUNT_ID}.dkr.ecr.$${ECR_AWS_REGION}.amazonaws.com && \
	docker tag lambda-slack-bot-chat-gpt-requester:latest $${ECR_AWS_ACCOUNT_ID}.dkr.ecr.$${ECR_AWS_REGION}.amazonaws.com/lambda-slack-bot-chat-gpt-requester:latest && \
	docker push $${ECR_AWS_ACCOUNT_ID}.dkr.ecr.$${ECR_AWS_REGION}.amazonaws.com/lambda-slack-bot-chat-gpt-requester:latest

push-image-gateway:
	set -a && source .env && set +a && \
	cd src_gateway && \
	make build-image && \
	aws ecr get-login-password --region $${ECR_AWS_REGION} | docker login --username AWS --password-stdin $${ECR_AWS_ACCOUNT_ID}.dkr.ecr.$${ECR_AWS_REGION}.amazonaws.com && \
	docker tag lambda-slack-bot-gateway:latest $${ECR_AWS_ACCOUNT_ID}.dkr.ecr.$${ECR_AWS_REGION}.amazonaws.com/lambda-slack-bot-gateway:latest && \
	docker push $${ECR_AWS_ACCOUNT_ID}.dkr.ecr.$${ECR_AWS_REGION}.amazonaws.com/lambda-slack-bot-gateway:latest
