# Model represents NYPL hold requests and includes method to post hold to Sierra.
class SierraRequest
  require 'json'
  require 'net/http'
  require 'uri'
  require_relative 'custom_logger.rb'
  require_relative 'location.rb'
  require_relative 'kms.rb'
  attr_accessor :json_body, :hold_request, :patron_id, :record_number, :pickup_location, :delivery_location, :bearer, :base_request_url

  # These codes will trigger an automatically successful response being sent to the HoldRequestResult stream.
  # Technically speaking, they are codes that prevent holds. But we're treating any requests that come through with them as successful.
  SUPPRESSION_CODES = ['BD', 'GO', 'IN', 'NC', 'NE', 'NI', 'NK', 'NO', 'NR', 'NS', 'NT', 'NU', 'NV', 'NX', 'NY', 'NZ', 'OB', 'OM', 'OP', 'OS', 'OZ', 'QP', 'RR', 'SA', 'SM', 'SP']

  def initialize(json_data)
    self.json_body = json_data
  end

  # Authorizes the request.
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

  # Uses set SUPPRESSION_CODES array to determine whether a hold is for a suppressed record.
  def suppressed?
    self.delivery_location != nil && SUPPRESSION_CODES.include?(self.delivery_location)
  end

  # Posts the processed request to Sierra.
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

    CustomLogger.new({ "level" => "INFO", "message" => "Sierra Post request response code: #{response.code}, response: #{response.body}"}).log_message
    response # returns empty content, either code 204 if success, 404 if not found, or 500 if error, so passing code along.
  end

  # Returns a 404 if initial Hold Request cannot be found.
  # Otherwise, builds the Sierra hold request and posts it.
  def self.process_request(json_data, hold_request_data={})
    hold_request = hold_request_data == {} ? HoldRequest.find(json_data["trackingId"]) : hold_request_data

    return { "code" => "404", "message" => "Hold request not found." } if hold_request["data"] == nil

    sierra_request = SierraRequest.build_new_sierra_request(hold_request["data"])

    response = sierra_request.post_request
    CustomLogger.new({ "level" => "INFO", "message" => "#{response}"}).log_message

    if response.is_a? String
      return { "code" => response, "message" => "Suppressed." }
    else
      return { "code" => response.code, "message" => response.body }
    end
  end

  # Takes discovered hold request data and builds a valid Sierra requests out of the information provided.
  # Also retrieves pickup location code based on presence of pickupLocation or deliveryLocation.
  def self.build_new_sierra_request(hold_request_data)
    p [102, hold_request_data]
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

  def get_holds(patron)
    p ['get holds', patron]
    p self.base_request_url
    uri = URI.parse("#{self.base_request_url}/patrons/#{patron}/holds")
    p ['uri', uri]
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/json"
    p 126
    p self.bearer
    request["Authorization"] = "Bearer #{self.bearer}"

    req_options = {
      use_ssl: uri.scheme == "https",
      read_timeout: 500
    }

    p 133
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    p [141, response]

    CustomLogger.new("level" => "INFO", "message" => "Header: #{response.header}, Body: #{response.body}").log_message
    JSON.parse(response.body)
  end

end
