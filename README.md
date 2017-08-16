# Recap Hold Request Consumer 

Work in this project was based in part on the work by Attila Domokos. Found here http://www.adomokos.com/2016/06/using-ruby-in-aws-lambda.html

## Requirements

* Node.js 6.10.2
* Ruby 2.2.0


## Installation

1. Clone the repo.
2. Install required dependencies.
   * Run `npm install` to install Node.js packages.
   * Run `BUNDLE_IGNORE_CONFIG=1 bundle install --path vendor` to install Ruby Gems.
   * If you have not already installed `node-lambda` as a global package, run `npm install -g node-lambda`.
3. Setup [configuration](#configuration) files.
   * Copy `.env.sample` file to `.env`.
   * Copy `config/var_env.env.sample` to `config/var_dev.env`.

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
