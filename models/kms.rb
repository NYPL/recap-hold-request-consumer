class Kms
  require 'aws-sdk'
  require 'base64'
  require 'json'

  def self.decrypt(encoded_secret)
    kms = Aws::KMS::Client.new(region: 'us-east-1')
    decoded_string = Base64.decode64(encoded_secret)
    begin
      cleartextkey = kms.decrypt(ciphertext_blob: decoded_string)
      cleartextkey.plaintext
    rescue Exception => e
      CustomLogger(:message => "Bad decryption of secret key", level: "ERROR").log_message
      nil
    end
  end
end