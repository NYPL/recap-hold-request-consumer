# Class that decrypts sensitive keys stored on AWS. 
class Kms
  require 'aws-sdk-kms'
  require 'base64'
  require 'json'

  # Decrypts an encoded secret string. Returns nil if error, plaintext key if success. 
  def self.decrypt(encoded_secret)
    # To work around https://github.com/aws/aws-sam-cli/issues/3118:
    ENV.delete "AWS_SESSION_TOKEN" if ENV['AWS_SESSION_TOKEN'] == ''

    kms = Aws::KMS::Client.new(region: 'us-east-1')
    decoded_string = Base64.decode64(encoded_secret)
    begin
      cleartextkey = kms.decrypt(ciphertext_blob: decoded_string)
      cleartextkey.plaintext
    rescue Exception => e
      $logger.error "Bad decryption of secret key: #{e}"
      nil
    end
  end
end
