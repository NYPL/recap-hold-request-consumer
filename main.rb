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

Dotenv.load('.env', 'var_app', './config/var_app')

event = []

if ENV['RUN_ENV'] == 'localhost'
  puts "Running as localhost ... "
  event = JSON.parse(File.read('./events/test_kinesis.json'))
else
  puts "Running on AWS ... "
  event = JSON.parse(STDIN.read)
end

event["Records"].each do |kinesis_record|
  # begin
    puts "Processing an event ... "
    json_data = Stream.decode(kinesis_record["kinesis"]["data"])
    hold_request = HoldRequest.find json_data["trackingId"]

    if hold_request == "404"
      puts "404 - No hold request found"
      { "code" => "404", "message" => "ERROR - Unable to find original hold request. #{kinesis_record}" }
    else
      puts "Routing hold request ... "
      puts json_data
      puts hold_request
      HoldRequest.new.route_request_with(json_data,hold_request)
    end
  # rescue Exception => e
  #   response = "ERROR - Unparseable data sent to RecapHoldRequestConsumer via ReCAP. #{kinesis_record}"
  #   puts response
  #   {"code" => "500", "message" => response}
  # end
end
