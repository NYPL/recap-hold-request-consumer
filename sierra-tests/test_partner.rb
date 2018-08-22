require 'json'
require_relative '../models/accept_item_request.rb'
require_relative './env.rb'
require_relative "./test/test#{ARGV[0]}.rb"

json_data = JSON_DATA
hold_request_data = HOLD_REQUEST_DATA

set_env
json_data = JSON.parse(json_data)
hold_request_data = JSON.parse(hold_request_data)
AcceptItemRequest.process_request(json_data, hold_request_data)
