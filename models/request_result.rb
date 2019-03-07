# Model representing the result message posted to Kinesis stream about everything that has gone on here -- good, bad, or otherwise.
class RequestResult
  require 'aws-sdk'
  require_relative './sierra_request.rb'

  # Sends a JSON message to Kinesis after encoding and formatting it.
  def self.send_message(json_message)
    message = Stream.encode(json_message)
    client = Aws::Kinesis::Client.new

    resp = client.put_record({
      stream_name: ENV["HOLD_REQUEST_RESULT_STREAM"],
      data: message,
      partition_key: SecureRandom.hex(20)
    })

    return_hash = {}

    if resp.successful?
      return_hash["code"] = "200"
      return_hash["message"] = json_message, resp
      CustomLogger.new({ "level" => "INFO", "message" => "Message sent to HoldRequestResult #{json_message}, #{resp}"}).log_message
    else
      return_hash["code"] = "500"
      return_hash["message"] = json_message, resp
      CustomLogger.new({ "level" => "ERROR", "message" => "FAILED to send message to HoldRequestResult #{json_message}, #{resp}.", "error_codename" => "FOUNTAIN PEN"}).log_message
    end
    return_hash
  end

  def self.handle_success(hold_request, type)
    CustomLogger.new({ "level" => "INFO", "message" => "Hold request successfully posted. HoldRequestId: #{hold_request["data"]["id"]}. JobId: #{hold_request["data"]["jobId"]}"}).log_message
    message_result = RequestResult.send_message({"jobId" => hold_request["data"]["jobId"], "success" => true, "holdRequestId" => hold_request["data"]["id"].to_i})
    {"code" => message_result["code"], "type" => type, "message" => message_result["message"]}
  end

  def self.handle_500_as_error(hold_request, message, message_hash, type)
    CustomLogger.new({ "level" => "ERROR", "message" => "Request errored out. HoldRequestId: #{hold_request["data"]["id"]}. JobId: #{hold_request["data"]["jobId"]}. Message Name: #{message_hash["message"]}. ", "error_codename" => "HIGHLIGHTER"}).log_message
    message_result = RequestResult.send_message({"jobId" => hold_request["data"]["jobId"], "success" => false, "error" => { "type" => "hold-request-error", "message" => message }, "holdRequestId" => hold_request["data"]["id"].to_i})
    {"code" => "500", "type" => type}
  end

  def self.already_sent_error?(message_hash)
    error_list = ["Your request has already been sent", "already on hold for or checked out to you"]
    hash = JSON.parse(message_hash["message"])
    (hash.is_a? Hash) && (hash["description"].is_a? String) && error_list.any? {|error| hash["description"].include?(error)}
  end

  def self.patron_already_has_hold?(hold_request)
    patron = hold_request["data"]["patron"]
    record = hold_request["data"]["record"]
    sierra_request = SierraRequest.build_new_sierra_request({})
    sierra_request.assign_bearer
    holds = sierra_request.get_holds(patron)
    (holds.is_a? Hash) && holds["entries"] && (holds["entries"].is_a? Array) && holds["entries"].any? do |entry|
      (entry.is_a? Hash) && (entry['record'].is_a? String) && entry['record'].include?(record)
    end
  end

  def self.is_actually_error?(hold_request, message_hash)
    !self.already_sent_error?(message_hash) || !self.patron_already_has_hold?(hold_request)
  end

  def self.handle_500(hold_request, message, message_hash, type)
    if self.is_actually_error?(hold_request, message_hash)
      self.handle_500_as_error(hold_request, message, message_hash, type)
    else
      self.handle_success(hold_request, type)
    end
  end

  # Crafts a message to post based on all available information.
  def self.process_response(message_hash,type=nil,json_data=nil,hold_request=nil)
    if json_data == nil || hold_request == nil || hold_request["data"] == nil
      CustomLogger.new({"level" => "ERROR", "message" => "Hold request failed. Key information missing or hold request data not found."}).log_message
      message_result = RequestResult.send_message({"jobId" => "", "success" => false, "error" => { "type" => "key-information-missing", "message" => "500: Hold request failed. Key information missing or hold request data not found" }, "holdRequestId" => json_data["trackingId"].to_i})
      { "code" => "500", "type" => type }
    elsif message_hash["code"] == nil
      message_result = RequestResult.send_message({"jobId" => hold_request["data"]["jobId"], "success" => false, "error" => { "type" => "recap-hold-request-consumer-error", "message" => "500: ReCAP hold request consumer failure. Valid response code not found." }, "holdRequestId" => hold_request["data"]["id"].to_i})
      { "code" => "500", "type" => type }
    elsif message_hash["code"] == "200" || message_hash["code"] == "204"
      self.handle_success(hold_request, type)
    elsif message_hash["code"] == "404"
      CustomLogger.new({ "level" => "INFO", "message" => "Request returned 404. HoldRequestId: #{hold_request["data"]["id"]}. JobId: #{hold_request["data"]["jobId"]}"}).log_message
      message_result = RequestResult.send_message({"jobId" => hold_request["data"]["jobId"], "success" => false, "error" => { "type" => "hold-request-not-found", "message" => "404: Hold request not found or deleted. Please try again." }, "holdRequestId" => hold_request["data"]["id"].to_i})
      {"code" => "404", "type" => type}
    else
      begin
        j = JSON.parse(message_hash["message"])
        message = "#{j["httpStatus"]} : #{j["description"]}"
      rescue Exception => e
        message = "500: recap hold request error. #{message_hash}"
      end
      self.handle_500(hold_request, message, message_hash, type)
    end
  end
end
