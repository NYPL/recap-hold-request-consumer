# Encoding and decoding messages with AVRO schemas. 
class Stream
  require 'aws-sdk'
  require 'base64'
  require 'avro'
  require 'json'

  # Processes binary and decodes based on avro schema. Takes string, returns JSON hash.
  def self.decode(encoded_data_string)
    schema = Avro::Schema.parse(File.open("RecapHoldRequest.avsc", "rb").read)
    writer = Avro::IO::DatumWriter.new(schema)

    avro_string = Base64.decode64(encoded_data_string)
    stringreader = StringIO.new(avro_string)
    decoder = Avro::IO::BinaryDecoder.new(stringreader)
    datumreader = Avro::IO::DatumReader.new(schema)
    read_value = datumreader.read(decoder)

    read_value
  end

  # Processes record and encodes it to send to HoldRequestResult stream
  # test message { "jobId": "123", "success": true, "error": { "message": "Test message", "type": "debug" }, "holdRequestId":12345 }
  def self.encode(json_message)
    schema = Avro::Schema.parse(File.open("HoldRequestResult.avsc", "rb").read)
    buffer = StringIO.new
    encoder = Avro::IO::BinaryEncoder.new buffer
    writer = Avro::IO::DatumWriter.new(schema)
    writer.write json_message, encoder
    buffer.rewind
    buffer.read
  end

end
