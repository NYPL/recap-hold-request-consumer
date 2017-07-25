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
      puts "Message sent to HoldRequestResult : #{json_message}"
    else
      return_hash["code"] = "500"
      return_hash["message"] = json_message
      puts "FAILED to send message to HoldRequestResult : #{json_message}."
    end
    return_hash
  end


  def self.process_response(message_hash,type=nil,json_data=nil,hold_request=nil)
    puts message_hash
    return { "code" => "500", "type" => type } if message_hash["code"] == nil || json_data == nil || hold_request == nil || hold_request["data"] == nil

    json_hash = { "jobId" => nil, }
    if message_hash["code"].scan("20").count > 0 #200 or 204
      # TODO: Get and parse message returned for more information. KrisKelly.
      puts "Hold request successfully posted. HoldRequestId: #{json_data["trackingId"]}. JobId: #{hold_request["data"]["jobId"]}"
      message_result = RequestResult.send_message({"jobId" => hold_request["data"]["jobId"], "success" => true, "holdRequestId" => json_data["trackingId"].to_i})
      {"code" => message_result["code"], "type" => type, "message" => message_result["message"]}
    elsif message_hash["code"] == "404"
      # TODO: Add error message to post. KrisKelly.
      puts "Request returned 404. HoldRequestId: #{json_data["trackingId"]}. JobId: #{hold_request["data"]["jobId"]}"
      message_result = RequestResult.send_message({"jobId" => hold_request["data"]["jobId"], "success" => false, "holdRequestId" => json_data["trackingId"].to_i})
      {"code" => "404", "type" => type}
    else
      puts "Request errored out. HoldRequestId: #{json_data["trackingId"]}. JobId: #{hold_request["data"]["jobId"]}"
      {"code" => "500", "type" => type}
    end
  end
end
