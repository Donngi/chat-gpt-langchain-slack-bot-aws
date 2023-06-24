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
define push_image
	set -a && source .env && set +a && \
	cd src_chat_gpt_requester && \
	make build-image && \
	LATEST_TAG=$$(aws ecr list-images --repository-name $(1) --output json | jq -r '.imageIds[].imageTag' | grep "^v[0-9]\+$$" | sed 's/v//g' | sort -nr | head -n1) && \
	NEW_TAG="v$$(( $${LATEST_TAG:-0} + 1))" && \
	aws ecr get-login-password --region $${ECR_AWS_REGION} | docker login --username AWS --password-stdin $${ECR_AWS_ACCOUNT_ID}.dkr.ecr.$${ECR_AWS_REGION}.amazonaws.com && \
	docker tag $(1):latest $${ECR_AWS_ACCOUNT_ID}.dkr.ecr.$${ECR_AWS_REGION}.amazonaws.com/$(1):$${NEW_TAG} && \
	docker push $${ECR_AWS_ACCOUNT_ID}.dkr.ecr.$${ECR_AWS_REGION}.amazonaws.com/$(1):$${NEW_TAG}
endef

push-images: push-image-chat-gpt-requester push-image-gateway

push-image-chat-gpt-requester:
	$(call push_image,lambda-slack-bot-chat-gpt-requester)

push-image-gateway:
	$(call push_image,lambda-slack-bot-gateway)

