class RequestResult
  require 'aws-sdk'

  def self.send_message(json_message)
    message = Stream.encode(json_message)
    client = Aws::Kinesis::Client.new(
      access_key_id: ENV['ACCESS_KEY_ID'],
      secret_access_key: ENV['SECRET_ACCESS_KEY'],
      region: 'us-east-1'
    )

    resp = client.put_record({
      stream_name: "HoldRequestResult",
      data: message,
      partition_key: SecureRandom.hex(20)
    })

    return_hash = {}
    
    if resp.successful?
      return_hash["code"] = "200"
      return_hash["message"] = json_message
      CustomLogger.new({ "level" => "INFO", "message" => "Message sent to HoldRequestResult #{json_message}"}).log_message
    else
      return_hash["code"] = "500"
      return_hash["message"] = json_message
      CustomLogger.new({ "level" => "ERROR", "message" => "FAILED to send message to HoldRequestResult #{json_message}.", "error_codename" => "FOUNTAIN PEN"}).log_message
    end
    return_hash
  end


  def self.process_response(message_hash,type=nil,json_data=nil,hold_request=nil)
    return { "code" => "500", "type" => type } if message_hash["code"] == nil || json_data == nil || hold_request == nil || hold_request["data"] == nil

    if message_hash["code"].scan("20").count > 0 #200 or 204
      CustomLogger.new({ "level" => "INFO", "message" => "Hold request successfully posted. HoldRequestId: #{hold_request["data"]["id"]}. JobId: #{hold_request["data"]["jobId"]}"}).log_message
      message_result = RequestResult.send_message({"jobId" => hold_request["data"]["jobId"], "success" => true, "holdRequestId" => hold_request["data"]["id"].to_i})
      {"code" => message_result["code"], "type" => type, "message" => message_result["message"]}
    elsif message_hash["code"] == "404"
      CustomLogger.new({ "level" => "INFO", "message" => "Request returned 404. HoldRequestId: #{hold_request["data"]["id"]}. JobId: #{hold_request["data"]["jobId"]}"}).log_message
      message_result = RequestResult.send_message({"jobId" => hold_request["data"]["jobId"], "success" => false, "error" => { "type" => "hold-request-not-found", "message" => "Hold request not found or deleted. Please try again." }, "holdRequestId" => hold_request["data"]["id"].to_i})
      {"code" => "404", "type" => type}
    else
      CustomLogger.new({ "level" => "ERROR", "message" => "Request errored out. HoldRequestId: #{hold_request["data"]["id"]}. JobId: #{hold_request["data"]["jobId"]}", "error_codename" => "HIGHLIGHTER"}).log_message
      message_result = RequestResult.send_message({"jobId" => hold_request["data"]["jobId"], "success" => false, "error" => { "type" => "hold-request-error", "message" => "Hold request errored out. Please try again." }, "holdRequestId" => hold_request["data"]["id"].to_i})
      {"code" => "500", "type" => type}
    end
  end
end
