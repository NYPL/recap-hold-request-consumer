OSXDIR=rhrc-1.0.0-osx
LAMBDADIR=rhrc-1.0.0-linux-x86_64

THIS_FILE := $(lastword $(MAKEFILE_LIST))

.DEFAULT_GOAL := help

package: ## Package the code for AWS Lambda
	@echo 'Package the app for deploy'
	@echo '--------------------------'
	@BUNDLE_IGNORE_CONFIG=1 bundle install --path vendor
	@rm -fr $(LAMBDADIR)
	@rm -fr deploy
	@mkdir -p $(LAMBDADIR)/lib/ruby
	@tar -xzf resources/traveling-ruby-20150715-2.2.2-linux-x86_64.tar.gz -C $(LAMBDADIR)/lib/ruby
	@mkdir $(LAMBDADIR)/lib/app
	@cp main.rb $(LAMBDADIR)/lib/app/rhrc.rb
	@mkdir $(LAMBDADIR)/lib/app/models
	@cp models/*.rb $(LAMBDADIR)/lib/app/models/
	@cp config/var_deploy.env $(LAMBDADIR)/var_app.env
	@cp events/test_kinesis.json $(LAMBDADIR)/test_kinesis.json
	@cp RecapHoldRequest.avsc $(LAMBDADIR)/RecapHoldRequest.avsc
	@cp HoldRequestResult.avsc $(LAMBDADIR)/HoldRequestResult.avsc
	@cp -pR vendor $(LAMBDADIR)/lib/
	@rm -fr $(LAMBDADIR)/lib/vendor/ruby/2.2.0/extensions
	@tar -xzf resources/json-1.8.2.tar.gz -C $(LAMBDADIR)/lib/vendor/ruby/
	@rm -f $(LAMBDADIR)/lib/vendor/*/*/cache/*
	@mkdir -p $(LAMBDADIR)/lib/vendor/.bundle
	@cp resources/bundler-config $(LAMBDADIR)/lib/vendor/.bundle/config
	@cp Gemfile $(LAMBDADIR)/lib/vendor/
	@cp Gemfile.lock $(LAMBDADIR)/lib/vendor/
	@cp resources/wrapper.sh $(LAMBDADIR)/rhrc
	@chmod +x $(LAMBDADIR)/rhrc
	@cp resources/index.js $(LAMBDADIR)/
	@cd $(LAMBDADIR) && zip -r rhrc.zip rhrc index.js var_app test_kinesis.json RecapHoldRequest.avsc HoldRequestResult.avsc lib/ > /dev/null
	@mkdir deploy
	@cd $(LAMBDADIR) && mv rhrc.zip ../deploy/
	@echo '... Done.'

create_development: ## Creates an AWS lambda function
	@cp config/var_dev.env config/var_deploy.env
	aws lambda create-function \
		--function-name RecapHoldRequestConsumer-development \
		--handler index.handler \
		--runtime nodejs6.10 \
		--memory 1024 \
		--timeout 10 \
		--description "Processes hold requests from recap" \
		--role arn:aws:iam::224280085904:role/lambda_basic_execution \
		--zip-file fileb://./deploy/rhrc.zip \
		--profile nypl-sandbox

deploy_development:  ## Deploys the latest version to AWS development
	@cp config/var_dev.env config/var_deploy.env
	@make package
	aws lambda update-function-code \
		--function-name RecapHoldRequestConsumer-development \
		--zip-file fileb://./deploy/rhrc.zip \
		--profile nypl-sandbox

create_qa:
	@cp config/var_qa.env config/var_deploy.env
	aws lambda create-function \
		--function-name RecapHoldRequestConsumer-qa \
		--handler index.handler \
		--runtime nodejs6.10 \
		--memory 1024 \
		--timeout 10 \
		--description "Processes hold requests from recap" \
		--role arn:aws:iam::946183545209:role/lambda-full-access \
		--zip-file fileb://./deploy/rhrc.zip \
		--profile nypl-digital-dev

deploy_qa: ## Deploys the latest version to AWS QA
	@cp config/var_qa.env config/var_deploy.env
	@make package
	aws lambda update-function-code \
		--function-name RecapHoldRequestConsumer-qa \
		--zip-file fileb://./deploy/rhrc.zip \
		--profile nypl-digital-dev

deploy_production: ## Deploys the latest version to AWS development
	@cp config/var_prod.env config/var_deploy.env
	@export AWS_DEFAULT_PROFILE=production
	@make package
	aws lambda update-function-code \
		--function-name RecapHoldRequestConsumer-production \
		--zip-file fileb://./deploy/rhrc.zip \
		--profile production

create_production:
	@cp config/var_prod.env config/var_deploy.env
	@export AWS_DEFAULT_PROFILE=production
	aws lambda create-function \
		--function-name RecapHoldRequestConsumer-production \
		--handler index.handler \
		--runtime nodejs6.10 \
		--memory 1024 \
		--timeout 10 \
		--description "Processes hold requests from recap" \
		--role arn:aws:iam::946183545209:role/lambda-full-access \
		--zip-file fileb://./deploy/rhrc.zip \
		--profile production

delete_development: ## Removes the Lambda
	@export AWS_DEFAULT_PROFILE=development
	aws lambda delete-function --function-name RecapHoldRequestConsumer-development

delete_qa: ## Removes the lambda
	@export AWS_DEFAULT_PROFILE=qa
	aws lambda delete-function --function-name RecapHoldRequestConsumer-qa

delete_production: ## Removes the lambda
	@export AWS_DEFAULT_PROFILE=production
	aws lambda delete-function --function-name RecapHoldRequestConsumer-production

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
