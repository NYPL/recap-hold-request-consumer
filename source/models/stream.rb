require 'aws-sdk'

class Stream
  
  AWS.config( :access_key_id => ENV[ACCESS_KEY_ID],
              :secret_access_key => ENV[SECRET_ACCESS_KEY])
  
  # The raw response read from AWS Kinesis stream
  def raw_response
  end

  # Processes binary and decodes based on avro schema.
  def avro_decode
  end

end