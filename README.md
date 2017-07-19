# Ruby Test Lambda

## Requirements

* Node.js 6.10.2
* Ruby 2.2.0


## Installation

1. Clone the repo.
2. Install required dependencies.
   * Run `npm install` to install Node.js packages.
   * Run `bundle install --deployment` to install Ruby Gems.
   * If you have not already installed `node-lambda` as a global package, run `npm install -g node-lambda`.
3. Setup [configuration](#configuration) files.
   * Copy `.env.sample` file to `.env`.
   * Copy `config/var_env.env.sample` to `config/var_dev.env`.

## Configuration

Various files are used to configure and deploy the Lambda.

### .env

`.env` is used *locally* for two purposes:

1. By `node-lambda` for deploying to and configuring Lambda in *all* environments.
   * You should use this file to configure the common settings for the Lambda
   (e.g. timeout, role, etc.) and include AWS credentials to deploy the Lambda.
2. To set local environment variables so the Lambda can be run and tested in a local environment.
   These parameters are ultimately set by the [var environment files](#var_environment) when the Lambda is deployed.

### package.json

Configures `npm run` deployment commands for each environment and sets the proper AWS Lambda VPC and
security group.

~~~~
"scripts": {
    "deploy-dev": "node-lambda deploy -e dev -f config/var_dev.env -S config/event_sources_dev.json",
    "deploy-qa": "node-lambda deploy -e qa -f config/var_qa.env -S config/event_sources_qa.json",
    "deploy-production": "node-lambda deploy -e production -f config/var_production.env -S config/event_sources_production.json",
    "test": "node-lambda run -j events/test_kinesis.json -x events/context.json"
},
~~~~

### var_app

Configures environment variables common to *all* environments.

### var_*environment*.env

Configures environment variables specific to each environment.

### event_sources_*environment*.json

Configures Lambda event sources (triggers) specific to each environment.

## Usage

### Process a Lambda Event

To use `node-lambda` to process the sample event(s), run:

~~~~
npm run test
~~~~

## Deployment

To deploy to an environment, run the corresponding command:

~~~~
npm run deploy-dev
~~~~

or

~~~~
npm run deploy-qa
~~~~
