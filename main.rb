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
require_relative 'models/kms.rb'

Dotenv.load('.env', './config/var_app.env')

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

    if hold_request == "404" || hold_request == "500"
      CustomLogger.new("level" => "ERROR", "message" => "No hold request found for #{json_data['trackingId'].to_i}. The hold request API may be down or the database may be unresponsive.", "error_codename" => "ERASER").log_message
      RequestResult.send_message({"jobId" => "", "success" => false, "holdRequestId" => json_data["trackingId"].to_i})
    else
      CustomLogger.new("level" => "INFO", "message" => "Kinesis decoded data.").log_message
      CustomLogger.new("level" => "INFO", "message" => "Found hold request data.").log_message
      HoldRequest.new.route_request_with(json_data,hold_request)
    end
  rescue Exception => e
    CustomLogger.new("level" => "ERROR", "message" => "#{e}", "error_codename" => "ROGET").log_message
  end
end
