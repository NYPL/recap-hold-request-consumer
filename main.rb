require 'aws-sdk-kms'
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
      event_data = Stream.decode(kinesis_record["kinesis"]["data"])
      hold_request = HoldRequest.find event_data["trackingId"]
      timestamp = kinesis_record["kinesis"]["approximateArrivalTimestamp"]

      if hold_request == "404" || hold_request == "500"
        $logger.error "No hold request found for #{event_data['trackingId'].to_i}. The hold request API may be down or the database may be unresponsive.", "error_codename" => "ERASER"
        RequestResult.send_message({"jobId" => "", "success" => false, "holdRequestId" => event_data["trackingId"].to_i})
      else
        $logger.info "Kinesis decoded data."
        $logger.info "Found hold request data."
        HoldRequest.new.route_request_with(event_data, hold_request, timestamp)
      end
    rescue Exception => e
      $logger.error "#{e}", "error_codename" => "ROGET"
    end
  end
end
