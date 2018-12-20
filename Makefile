.ONESHELL:
SHELL := /bin/bash

VARS="tfvars/terraform.tfvars"
CURRENT_FOLDER=$(shell basename "$$(pwd)")
S3_BUCKET="sudoers-terraform-state"
DYNAMODB_TABLE="sudoers-terraform-state"
STATE_REGION="eu-west-1"

# Colors
BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)

.PHONY: setup plan apply

default: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

check-env: ## Check if AWS environment variables is set
	@if [ -z $(AWS_ACCESS_KEY_ID) ]; then \
		echo "$(BOLD)$(RED)AWS_ACCESS_KEY_ID is not set$(RESET)"; \
		exit 1; \
	 fi
	@if [ -z $(AWS_SECRET_ACCESS_KEY) ]; then \
		echo "$(BOLD)$(RED)AWS_SECRET_ACCESS_KEY is not set$(RESET)"; \
		exit 1; \
	fi
	@if [ ! -f $(VARS) ]; then \
		echo "$(BOLD)$(RED)Var file is not availabke$(RESET)"; \
		exit 1; \
	fi

setup: ## Configure the tfstate backend and update any modules
	@ echo "$(BOLD)Verifying that the S3 bucket $(S3_BUCKET) for remote state exists$(RESET)"
	@ if ! aws s3api head-bucket --region $(STATE_REGION) --bucket $(S3_BUCKET) > /dev/null 2>&1 ; then \
		echo "$(BOLD)S3 bucket $(S3_BUCKET) was not found, creating new bucket with versioning enabled to store tfstate$(RESET)"; \
		aws s3api create-bucket \
			--bucket $(S3_BUCKET) \
			--acl private \
			--region $(STATE_REGION) \
			--create-bucket-configuration LocationConstraint=$(STATE_REGION) > /dev/null 2>&1 ; \
		aws s3api put-bucket-versioning \
			--bucket $(S3_BUCKET) \
			--versioning-configuration Status=Enabled > /dev/null 2>&1 ; \
		echo "$(BOLD)$(GREEN)S3 bucket $(S3_BUCKET) created$(RESET)"; \
	 else \
	        echo "$(BOLD)$(GREEN)S3 bucket $(S3_BUCKET) exists$(RESET)"; \
	 fi
	@echo "$(BOLD)Verifying that the DynamoDB table exists for remote state locking$(RESET)"
	@if ! aws dynamodb describe-table --table-name $(DYNAMODB_TABLE) > /dev/null 2>&1 ; then \
		echo "$(BOLD)DynamoDB table $(DYNAMODB_TABLE) was not found, creating new DynamoDB table to maintain locks$(RESET)"; \
		aws dynamodb create-table \
        		--region $(STATE_REGION) \
        		--table-name $(DYNAMODB_TABLE) \
        		--attribute-definitions AttributeName=LockID,AttributeType=S \
        		--key-schema AttributeName=LockID,KeyType=HASH \
        		--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 > /dev/null 2>&1 ; \
		echo "$(BOLD)$(GREEN)DynamoDB table $(DYNAMODB_TABLE) created$(RESET)"; \
	 else \
		echo "$(BOLD)$(GREEN)DynamoDB Table $(DYNAMODB_TABLE) exists$(RESET)"; \
	 fi
	@echo "$(BOLD)Configuring the terraform backend$(RESET)"
	@terraform init \
		-input=false \
		-lock=true \
		-upgrade=false \
		-verify-plugins=true \
		-backend=true \
		-backend-config="region=$(STATE_REGION)" \
		-backend-config="bucket=$(S3_BUCKET)" \
		-backend-config="key=sudoers-aws/terraform.tfstate" \
		-backend-config="dynamodb_table=$(DYNAMODB_TABLE)"

plan: setup ## Run terraform plan
	@terraform plan \
		-lock=true \
		-input=false \
		-var-file="$(VARS)"

apply: setup ## Run terraform apply
	@terraform apply \
		-auto-approve=true \
		-input=false \
		-var-file="$(VARS)"

show: ## Run terraform show
	@terraform show

output: ## Run terraform output
	@terraform output
