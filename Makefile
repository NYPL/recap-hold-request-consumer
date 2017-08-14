OSXDIR=rhrc-1.0.0-osx
LAMBDADIR=rhrc-1.0.0-linux-x86_64

THIS_FILE := $(lastword $(MAKEFILE_LIST))

.DEFAULT_GOAL := help

run: ## Runs the code locally
	@echo 'Run the app locally'
	@echo '-------------------'
	@rm -fr $(OSXDIR)
	@mkdir -p $(OSXDIR)/lib/ruby
	@tar -xzf resources/traveling-ruby-20150715-2.2.2-osx.tar.gz -C $(OSXDIR)/lib/ruby
	@mkdir $(OSXDIR)/lib/app
	@cp main.rb $(OSXDIR)/lib/app/rhrc.rb
	@mkdir $(OSXDIR)/lib/app/models
	@cp -pR vendor $(OSXDIR)/lib/
	@rm -f $(OSXDIR)/lib/vendor/*/*/cache/*
	@mkdir -p $(OSXDIR)/lib/vendor/.bundle
	@cp resources/bundler-config $(OSXDIR)/lib/vendor/.bundle/config
	@cp Gemfile $(OSXDIR)/lib/vendor/
	@cp Gemfile.lock $(OSXDIR)/lib/vendor/
	@cp resources/wrapper.sh $(OSXDIR)/rhrc
	@chmod +x $(OSXDIR)/rhrc
	@cd $(OSXDIR) && ./rhrc

package: ## Package the code for AWS Lambda
	@echo 'Package the app for deploy'
	@echo '--------------------------'
	@rm -fr $(LAMBDADIR)
	@rm -fr deploy
	@mkdir -p $(LAMBDADIR)/lib/ruby
	@tar -xzf resources/traveling-ruby-20150715-2.2.2-linux-x86_64.tar.gz -C $(LAMBDADIR)/lib/ruby
	@mkdir $(LAMBDADIR)/lib/app
	@cp main.rb $(LAMBDADIR)/lib/app/rhrc.rb
	@mkdir $(LAMBDADIR)/lib/app/models
	@cp models/*.rb $(LAMBDADIR)/lib/app/models/
	@cp config/var_dev.env $(LAMBDADIR)/var_app
	@cp events/test_kinesis.json $(LAMBDADIR)/test_kinesis.json
	@cp RecapHoldRequest.avsc $(LAMBDADIR)/RecapHoldRequest.avsc
	@cp HoldRequestResult.avsc $(LAMBDADIR)/HoldRequestResult.avsc
	@cp -pR vendor $(LAMBDADIR)/lib/
	@rm -fr $(LAMBDADIR)/lib/vendor/ruby/2.2.0/extensions
	@tar -xzf resources/nokogiri-1.6.6.2.tar.gz -C $(LAMBDADIR)/lib/vendor/ruby/
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

create: ## Creates an AWS lambda function
	aws lambda create-function \
		--function-name recapHoldRequestConsumer-development \
		--handler index.handler \
		--runtime nodejs4.3 \
		--memory 1024 \
		--timeout 10 \
		--description "Processes hold requests from recap" \
		--role arn:aws:iam::224280085904:role/lambda_basic_execution \
		--zip-file fileb://./deploy/rhrc.zip

publish: package ## Deploys the latest version to AWS
	aws lambda update-function-code \
		--function-name recapHoldRequestConsumer-development \
		--zip-file fileb://./deploy/rhrc.zip

delete: ## Removes the Lambda
	aws lambda delete-function --function-name recapHoldRequestConsumer-development

invoke: ## Invoke the AWS Lambda in the command line
	rm -fr tmp && mkdir tmp
	aws lambda invoke \
	--invocation-type RequestResponse \
	--function-name recapHoldRequestConsumer-development \
	--log-type Tail \
	--region us-east-1 \
	--payload '{"name":"John Adam Smith"}' \
	tmp/outfile.txt \
	| jq -r '.LogResult' | base64 -D

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
