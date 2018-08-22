# Recap Hold Request Consumer

Work in this project was based in part on the work by Attila Domokos. Found here http://www.adomokos.com/2016/06/using-ruby-in-aws-lambda.html

## Requirements

* Node.js 6.10.2
* Ruby 2.2.0


## Installation

1. Clone the repo.
2. Install required dependencies.
   * Run `BUNDLE_IGNORE_CONFIG=1 bundle install --path vendor` to install Ruby Gems. The `--path vendor` part is IMPORTANT. Don't forget it.
   * If you have not already installed `node-lambda` as a global package, run `npm install -g node-lambda`.
   * This app uses Traveling Ruby
3. Setup [configuration](#configuration) files.
   * Copy `.env.sample` file to `.env`.
   * Copy `config/var_env.env.sample` to `config/var_app.env`.

## Configuration

Various files are used to configure and deploy the Lambda. Set yours up by creating `~./aws/credentials`

This lambda currently deploys to a development and a production environment. Recommend a credential file in this format:

    [default]
    region=us-east-1
    output=json
    aws_access_key_id=DEV_ACCESS_KEY_ID
    aws_secret_access_key=DEV_SECRET_ACCESS_KEY

    [development]
    region=us-east-1
    output=json
    aws_access_key_id=DEV_ACCESS_KEY_ID
    aws_secret_access_key=DEV_SECRET_ACCESS_KEY

    [production]
    region=us-east-1
    output=json
    aws_access_key_id=PROD_ACCESS_KEY_iD
    aws_secret_access_key=PROD_SECRET_ACCESS_KEY

### .env

`.env` is used *locally* for two purposes:

1. By `node-lambda` for deploying to and configuring Lambda in *all* environments.
   * You should use this file to configure the common settings for the Lambda
   (e.g. timeout, role, etc.) and include AWS credentials to deploy the Lambda.
2. To set local environment variables so the Lambda can be run and tested in a local environment.
   These parameters are ultimately set by the [var environment files](#var_environment) when the Lambda is deployed.

### Makefile

The Makefile is responsible for packaging the app and its dependencies and pushing it all to Amazon.

### var_*environment*.env

Configures environment variables specific to each environment. var_dev.env settings will be packaged on development deployment. var_prod.env will be packaged on production deployment. var_app.env is for local settings.

### test_kinesis.json

Change this file to configure a test of sample kinesis data.

### context.json

An empty hash, but important for node-lambda.

### Process a Lambda Event

To use `node-lambda` to process the sample event(s), run (will process `test_kinesis.json`):

~~~~
node-lambda run
~~~~

Make sure that `RUN_ENV` in `var_app.env` is set to `localhost`, otherwise it will wait for stream events.

You can also invoke `main.rb` (or any other .rb file in the app) directly by running:

~~~~
bundle exec ruby main.rb
~~~~

The lambda will process using the default credentials from your aws configuration if you have created
`~./aws/credentials` as recommended above

## Deployment

To deploy to an environment, run the corresponding command:

~~~~
make deploy_development
~~~~

or

~~~~
make deploy_production
~~~~

## Testing

The unit tests for the app are found in the `spec` directory. To run the full set, run:

~~~~
bundle exec rspec
~~~~

You can also run any of them directly, e.g.:

~~~~
bundle exec rspec ./spec/main_spec.rb
~~~~

Tests currently require a 404, 500, and timeout mocked response (currently set-up to run via `mocky.io`). Examples are included in the sample `var_app.env` file. Make sure they're present and valid before running tests.


We also have tests for the Sierra APIs. These are contained in the scripts `sierra-tests/test_nypl.rb`, which tests the Sierra REST API, and `sierra-tests/test_partner.rb` which tests Sierra NCIP AcceptItem.
To run these tests, make sure `sierra-tests/env.rb` contains any changes you want to make to environmental variables then run:

~~~~
bundle exec [script] [number]
~~~~

Where [number] matches the number of the test you want to run (these are in `sierra-tests/test`).
Each test contains a description of the test and the result it returned when it was tried, as well as a note as to whether it is intended for NCIP or REST API. Keep in mind that the test results may change since Sierra will reject a hold request that already exists.

To create your own tests, most of the fields are irrelevant, but the following fields matter:

For the REST API:
  In HOLD_REQUEST_DATA:
  * patron ( a patron id)
  * record (a record id, i.e. an item id)
  * deliveryLocation
For NCIP:
  In JSON_DATA:
  * patron barcode
  * item barcode
  * description (should have a title, author, and call number)
  In HOLD_REQUEST_DATA:
  * deliveryLocation
