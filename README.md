# Recap Hold Request Consumer

This is a consumer for handling hold requests from ReCAP for NYPL and partner patrons.

## Purpose

This consumer lambda reads events on the RecapHoldRequest streams and processes them:
1. Fetch hold-request from the HoldRequestService based on `trackingId`
2. When `owner` is 'NYPL', uses the Sierra API to create a hold-request for the patron
3. When `owner` is other than 'NYPL', creates a temporary item in Sierra using NCIP

## Installation

```
bundle install; bundle install --deployment
```

## Configuration

### var_*environment*.env

Configures environment variables specific to each environment. var_dev.env settings will be packaged on development deployment. var_prod.env will be packaged on production deployment. var_app.env is for local settings.

### Process a Lambda Event

Use sam to process events locally:
```
sam local invoke --event events/[choose your event file] --region us-east-1 --template sam.local.yml --profile [aws profile]
```

## Testing

The unit tests for the app are found in the `spec` directory. To run the full set, run:

~~~~
bundle exec rspec -fd
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

## Contributing

This repo uses the [Development-QA-Main Git Workflow](https://github.com/NYPL/engineering-general/blob/master/standards/git-workflow.md#development-qa-main)
