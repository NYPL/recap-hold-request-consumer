# Model representing the result message posted to Kinesis stream about everything that has gone on here -- good, bad, or otherwise. 
class RequestResult
  require 'aws-sdk'

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

  # Crafts a message to post based on all available information. 
  def self.process_response(message_hash,type=nil,json_data=nil,hold_request=nil)
    if json_data == nil || hold_request == nil || hold_request["data"] == nil
      CustomLogger.new({"level" => "ERROR", "message" => "Hold request failed. Key information missing or hold request data not found."}).log_message
      message_result = RequestResult.send_message({"jobId" => "", "success" => false, "holdRequestId" => json_data["trackingId"].to_i})
      { "code" => "500", "type" => type }
    elsif message_hash["code"] == nil
      message_result = RequestResult.send_message({"jobId" => hold_request["data"]["jobId"], "success" => false, "holdRequestId" => hold_request["data"]["id"].to_i})
      { "code" => "500", "type" => type }
    elsif message_hash["code"] == "200" || message_hash["code"] == "204"
      CustomLogger.new({ "level" => "INFO", "message" => "Hold request successfully posted. HoldRequestId: #{hold_request["data"]["id"]}. JobId: #{hold_request["data"]["jobId"]}"}).log_message
      message_result = RequestResult.send_message({"jobId" => hold_request["data"]["jobId"], "success" => true, "holdRequestId" => hold_request["data"]["id"].to_i})
      {"code" => message_result["code"], "type" => type, "message" => message_result["message"]}
    elsif message_hash["code"] == "404"
      CustomLogger.new({ "level" => "INFO", "message" => "Request returned 404. HoldRequestId: #{hold_request["data"]["id"]}. JobId: #{hold_request["data"]["jobId"]}"}).log_message
      message_result = RequestResult.send_message({"jobId" => hold_request["data"]["jobId"], "success" => false, "error" => { "type" => "hold-request-not-found", "message" => "Hold request not found or deleted. Please try again." }, "holdRequestId" => hold_request["data"]["id"].to_i})
      {"code" => "404", "type" => type}
    else
      CustomLogger.new({ "level" => "ERROR", "message" => "Request errored out. HoldRequestId: #{hold_request["data"]["id"]}. JobId: #{hold_request["data"]["jobId"]}", "error_codename" => "HIGHLIGHTER"}).log_message
      message_result = RequestResult.send_message({"jobId" => hold_request["data"]["jobId"], "success" => false, "error" => { "type" => "hold-request-error", "message" => "Hold request errored out. #{message_hash}" }, "holdRequestId" => hold_request["data"]["id"].to_i})
      {"code" => "500", "type" => type}
    end
  end
end
