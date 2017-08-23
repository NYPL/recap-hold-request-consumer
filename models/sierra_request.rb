class SierraRequest
  require 'json'
  require 'net/http'
  require 'uri'
  attr_accessor :json_body, :hold_request, :patron_id, :record_number, :pickup_location, :delivery_location, :bearer, :base_request_url

  SUPPRESSION_CODES = ['GO','NC','NY','NI','NK','NT','NX','NV','SM','SA','NS','SP','NE','IN','NU','RR','QP','BD']

  def initialize(json_data)
    self.json_body = json_data
  end

  def assign_bearer
    begin
      uri = URI.parse("#{self.base_request_url}/token")
      request = Net::HTTP::Post.new(uri)
      request.basic_auth(Kms.decrypt(ENV['ENCODED_SIERRA_ID']), Kms.decrypt(ENV['ENCODED_SIERRA_SECRET']))
      request.set_form_data(
        "grant_type" => "client_credentials"
      )

      req_options = {
        use_ssl: uri.scheme == "https",
        request_timeout: 500
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      if response.code == '200'
        self.bearer = JSON.parse(response.body)["access_token"]
      end
    rescue Exception => e
      CustomLogger.new({"level" => "ERROR", "message" => "Failed to get authorization token for Sierra Request: #{e}", "error_codename" => "BLOTTER"})
      self.bearer = nil
    end
  end

  def suppressed?
    self.delivery_location != nil && SUPPRESSION_CODES.include?(self.delivery_location)
  end

  def post_request
    return "204" if self.suppressed? 
    uri = URI.parse("#{self.base_request_url}/patrons/#{self.patron_id}/holds/requests")

    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{self.bearer}"
    
    request.body = JSON.dump({
      "recordType" => "i", #TODO: This may change at a later date, but for now we are only doing item requests. KAK.
      "recordNumber" => self.record_number.to_i,
      "pickupLocation" => self.pickup_location
    })

    req_options = {
      use_ssl: uri.scheme == "https",
      read_timeout: 500
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    CustomLogger.new({ "level" => "INFO", "message" => "Sierra Post request response code: #{response.code}, request: #{request.body}, response: #{response.body}"}).log_message
    response # returns empty content, either code 204 if success, 404 if not found, or 500 if error, so passing code along. 
  end

  def self.process_request(json_data, hold_request_data={})
    hold_request = hold_request_data == {} ? HoldRequest.find(json_data["trackingId"]) : hold_request_data

    return { "code" => "404", "message" => "Hold request not found." } if hold_request["data"] == nil

    sierra_request = SierraRequest.build_new_sierra_request(hold_request["data"])

    response = sierra_request.post_request
    CustomLogger.new({ "level" => "INFO", "message" => "#{response}"}).log_message

    return { "code" => response.code, "message" => response.body } 
  end

  def self.build_new_sierra_request(hold_request_data)
    CustomLogger.new("level" => "info", "message" => "Processing Sierra NYPL Request: #{hold_request_data}")
    sierra_request = SierraRequest.new(hold_request_data)
    sierra_request.patron_id = hold_request_data["patron"]
    sierra_request.record_number = hold_request_data["record"]
    sierra_request.delivery_location = hold_request_data["deliveryLocation"]
    sierra_request.base_request_url = ENV['SIERRA_URL']
    sierra_request.assign_bearer

    if hold_request_data["pickupLocation"] != nil && hold_request_data["pickupLocation"] != [] && hold_request_data["pickupLocation"] != ""
      sierra_request.pickup_location = hold_request_data["pickupLocation"]
    else
      sierra_request.pickup_location = Location.get_pickup_for(hold_request_data["deliveryLocation"])
    end

    sierra_request
  end

end
