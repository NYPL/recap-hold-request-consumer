require 'aws-sdk'
require 'aws/kclrb'
require 'json'
require 'dotenv'
require 'require_all'
require 'io/console'
require 'nypl_log_formatter'

require_relative 'models/stream.rb'
require_relative 'models/hold_request.rb'
require_relative 'models/sierra_request.rb'
require_relative 'models/request_result.rb'
require_relative 'models/location.rb'
require_relative 'models/custom_logger.rb'
require_relative 'models/kms.rb'


def init
  return if $initialized

  # Instantiate a global logger
  $logger = NyplLogFormatter.new(STDOUT, level: ENV['LOG_LEVEL'] || 'info')

  $initialized = true
end

def handle_event(event:, context:)
  init

  event["Records"].each do |kinesis_record|
    begin
      json_data = Stream.decode(kinesis_record["kinesis"]["data"])
      hold_request = HoldRequest.find json_data["trackingId"]
      timestamp = kinesis_record["kinesis"]["approximateArrivalTimestamp"]

      if hold_request == "404" || hold_request == "500"
        CustomLogger.new("level" => "ERROR", "message" => "No hold request found for #{json_data['trackingId'].to_i}. The hold request API may be down or the database may be unresponsive.", "error_codename" => "ERASER").log_message
        RequestResult.send_message({"jobId" => "", "success" => false, "holdRequestId" => json_data["trackingId"].to_i})
      else
        CustomLogger.new("level" => "INFO", "message" => "Kinesis decoded data.").log_message
        CustomLogger.new("level" => "INFO", "message" => "Found hold request data.").log_message
        HoldRequest.new.route_request_with(json_data, hold_request, timestamp)
      end
    rescue Exception => e
      CustomLogger.new("level" => "ERROR", "message" => "#{e}", "error_codename" => "ROGET").log_message
    end
  end
end
