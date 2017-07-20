class SierraRequest
  require 'json'
  require 'net/http'
  require 'uri'
  attr_accessor :json_body, :hold_request, :patron_id, :record_number, :pickup_location, :request_uri

  SUPPRESSION_CODES = ['NE', 'GO', 'NC', 'NI', 'NK', 'NS', 'NT', 'NU', 'NV', 'NX', 'NY', 'SA', 'SM', 'SP']

  def initialize(json_data)
    self.json_body = json_data
  end

  def self.get_bearer
    uri = URI.parse("#{ENV['SIERRA_URL']}/token")
    request = Net::HTTP::Post.new(uri)
    request.basic_auth(ENV['SIERRA_ID'], ENV['SIERRA_SECRET'])
    request.set_form_data(
      "grant_type" => "client_credentials"
    )

    req_options = {
      use_ssl: uri.scheme == "https"
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    if response.code == '200'
      JSON.parse(response.body)["access_token"]
    end
  end

  def suppressed?
    json_body["data"]["deliveryLocation"] && SUPPRESSION_CODES.include?(json_body["data"]["deliveryLocation"])
  end

  def post_request
    return "204" if self.suppressed? 

    uri = URI.parse("#{ENV['SIERRA_URL']}/patrons/#{self.patron_id}/holds/requests")

    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{SierraRequest.get_bearer}"
    request["Cache-Control"] = "no-cache"
    
    request.body = JSON.dump({
      "recordType" => "i", #TODO: This may change at a later date, but for now we are only doing item requests. KAK.
      "recordNumber" => self.record_number,
      "pickupLocation" => self.pickup_location
    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    response.code # returns empty content, either code 204 if success, 404 if not found, or 500 if error, so passing code along. 
  end

  def self.process_request(json_data)
    hold_request = HoldRequest.find json_data["id"] 
    
    return "404" if hold_request["data"] == nil

    sierra_request = SierraRequest.new(json_data)
    sierra_request.patron_id = hold_request["data"]["patron"]
    sierra_request.record_number = hold_request["data"]["record"]

    if hold_request["data"]["pickupLocation"] != nil || hold_request["data"]["pickupLocation"] != []
      sierra_request.pickup_location = hold_request["data"]["pickupLocation"]
    else
      sierra_request.pickup_location = Location.get_pickup_for(hold_request["data"]["deliveryLocation"])
    end

    response = sierra_request.post_request
    response
  end

end
