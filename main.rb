#!/usr/bin/env ruby
require 'aws-sdk'
require 'aws/kclrb'
require 'json'
require 'dotenv'
require 'require_all'
require 'io/console'
require_relative 'models/accept_item_request.rb'
require_relative 'models/stream.rb'
require_relative 'models/hold_request.rb'
require_relative 'models/sierra_request.rb'
require_relative 'models/request_result.rb'
require_relative 'models/location.rb'
require_relative 'models/custom_logger.rb'

Dotenv.load('.env', 'var_app', './config/var_app')

event = []

if ENV['RUN_ENV'] == 'localhost'
  event = JSON.parse(File.read('./events/test_kinesis.json'))
else
  event = JSON.parse(STDIN.read)
end

event["Records"].each do |kinesis_record|
  begin
    json_data = Stream.decode(kinesis_record["kinesis"]["data"])
    hold_request = HoldRequest.find json_data["trackingId"]
    if hold_request == "404"
      CustomLogger.new("level" => "ERROR", "message" => "No hold request found", "error_codename" => "ERASER")
    else
      CustomLogger.new("level" => "INFO", "message" => "Kinesis decoded data: #{json_data}")
      CustomLogger.new("level" => "INFO", "message" => "Found hold request data: #{hold_request}")
      HoldRequest.new.route_request_with(json_data,hold_request)
    end
  rescue Exception => e
    CustomLogger.new("level" => "ERROR", "message" => "Unparseable data sent to RecapHoldRequestConsumer via ReCAP. #{kinesis_record}", "error_codename" => "ROGET")
  end
end
