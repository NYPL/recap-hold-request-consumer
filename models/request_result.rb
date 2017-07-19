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

    if resp.successful?
      puts "Message sent to HoldRequestResult : #{json_message}"
    else
      puts "FAILED to send message to HoldRequestResult : #{json_message}."
    end
  end


  def self.process_response(message_hash)
    puts message_hash
    # if res.code.to_s.scan("20").count > 0 #200 or 204
    #   # TODO: Get and parse message returned from Sierra for more information. KrisKelly.
    #   puts "Hold request successfully posted to NCIP. HoldRequestId: #{json_data["id"]}. JobId: #{hold_request["data"]["jobId"]}"
    #   RequestResult.send_message({"success":true, "holdRequestId": json_data["id"], "jobId": hold_request["data"]["jobId"]})
    # elsif res.code.to_s == "404"
    #   # TODO: Add error message to post. KrisKelly.
    #   puts "NCIP returned 404. HoldRequestId: #{json_data["id"]}. JobId: #{hold_request["data"]["jobId"]}"
    #   RequestResult.send_message({"success":false, "holdRequestId": json_data["id"], "jobId": hold_request["data"]["jobId"]})
    # else
    #   puts "NCIP errored out. HoldRequestId: #{json_data["id"]}. JobId: #{hold_request["data"]["jobId"]}"
    #   puts res.code
    #   puts res.body
    #   RequestResult.send_message({"success":false, "holdRequestId": json_data["id"], "jobId": hold_request["data"]["jobId"]})
    # end
  end
end
