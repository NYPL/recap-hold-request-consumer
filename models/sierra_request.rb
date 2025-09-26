# Model represents NYPL hold requests and includes method to post hold to Sierra.
class SierraRequest
  require 'json'
  require 'net/http'
  require 'uri'

  require_relative 'location.rb'
  require_relative 'kms.rb'
  require_relative 'timeout_response.rb'
  require_relative 'sierra_virtual_record'

  attr_accessor :json_body, :hold_request, :patron_id, :record_number, :pickup_location, :delivery_location, :bearer, :base_request_url

  # These codes will trigger an automatically successful response being sent to the HoldRequestResult stream.
  # Technically speaking, they are codes that prevent holds. But we're treating any requests that come through with them as successful.
  # TODO: Can we make this data driven using nypl-core?
  SUPPRESSION_CODES = ['BD', 'GO', 'IN', 'NC', 'NE', 'NI', 'NK', 'NT', 'NU', 'NX', 'NY', 'OB', 'OL', 'OM', 'OP', 'OS', 'OZ', 'QP', 'RR', 'OI']

  # These location codes are also staff-only locations, but
  #  1) we do attempt to place a hold on items sent to these locations and
  #  2) if the hold fails, we should ignore it (because it's probably just a
  #     suppressed item)
  HOLD_OPTIONAL_STAFF_LOCATIONS = ['NO', 'NR', 'NS', 'NV', 'NZ', 'SA', 'SM', 'SP']

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
      $logger.error "Failed to get authorization token for Sierra Request: #{e}", "error_codename" => "BLOTTER"
      self.bearer = nil
    end
  end

  # Uses set SUPPRESSION_CODES array to determine whether a hold is for a suppressed record.
  def suppressed?
    self.delivery_location != nil && SUPPRESSION_CODES.include?(self.delivery_location)
  end

  def delete_record(record_id, record_type)
    uri = URI.parse("#{self.base_request_url}/#{record_type}s/#{record_id}")
    
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{self.bearer}"
    req_options = {
      use_ssl: uri.scheme == "https",
      read_timeout: 10
    }
    $logger.debug "Posting #{record_type} deletion for otf #{record_type}: #{record_id} to #{uri}"
    begin 
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
    rescue Exception => e
      $logger.error "Sierra delete #{record_type} error: #{e.message}"
      response = TimeoutResponse.new
    end 
  end


  # Posts the processed request to Sierra.
  def post_request
    return "204" if self.suppressed?
    uri = URI.parse("#{self.base_request_url}/patrons/#{self.patron_id}/holds/requests")

    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{self.bearer}"

    request.body = JSON.dump({
      # statgroup code 501 indicates physical request. this was added to 
      # generate reports on usage of request buttons.
      "statgroup": 501,
      "recordType" => "i", #TODO: This may change at a later date, but for now we are only doing item requests. KAK.
      "recordNumber" => self.record_number.to_i,
      "pickupLocation" => self.pickup_location
    })
    $logger.debug "Posting hold-request: #{request.body} to #{uri}"

    req_options = {
      use_ssl: uri.scheme == "https",
      read_timeout: 10
    }

    begin
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
    rescue Exception => e
      $logger.error "Sierra post_request error: #{e.message}"
      response = TimeoutResponse.new
    end

    $logger.debug "Sierra Post request response code: #{response.code}, response: #{response.body}"
    response # returns empty content, either code 204 if success, 404 if not found, or 500 if error, so passing code along.
  end

  # Process json_data (from original kinesis event) and hold_request_data
  # (instance of HoldRequest, typically identified by json_data.trackingId)
  #
  # Returns a 404 if initial Hold Request cannot be found.
  # Otherwise, builds the Sierra hold request and posts it.
  def self.process_item_in_sierra(json_data, hold_request_data={})
    hold_request = hold_request_data == {} ? HoldRequest.find(json_data["trackingId"]) : hold_request_data

    return { "code" => "404", "message" => "Hold request not found." } if hold_request["data"] == nil

    sierra_request = SierraRequest.build_new_sierra_request(hold_request["data"])

    response = sierra_request.post_request

    if response.is_a? String
      return { "code" => response, "message" => "Suppressed." }
    else
      return { "code" => response.code, "message" => response.body }
    end
  end

  # Process recap_hold_request (from original kinesis event)
  #
  # Returns a hash with 'code' and 'message' representing result
  def self.process_partner_item(recap_hold_request)
    return {"code" => "404", "message" => "missing hold request id (trackingId)" } unless recap_hold_request['trackingId']

    hold_request = HoldRequest.find(recap_hold_request["trackingId"])

    return {"code" => "404", "message" => "missing hold request data" } if hold_request["data"] == nil
    return {"code" => "500", "message" => "missing item description data" } if recap_hold_request["description"] == nil

    hold_data = hold_request["data"]

    # If title indicates item is in Harvard HD, add [HD] prefix:
    title = recap_hold_request["description"]["title"] || ''
    if recap_hold_request['owningInstitutionId'] == 'HL' && title.match(/\[HD\]$/)
      title = "[HD] #{title}"
    end

    virtual_record = SierraVirtualRecord.create({
      item_barcode: recap_hold_request["itemBarcode"],
      call_number: recap_hold_request["description"]["callNumber"],
      author: recap_hold_request["description"]["author"],
      title: title,
      item_id: hold_data['record'],
      item_nypl_source: hold_data['nyplSource'],
    })

    # Now that we've localized the partner item as an NYPL item, we can process
    # it _as_ an NYPL item:
    translated_hold_request = hold_request
    translated_hold_request['data']['record'] = virtual_record.item_id
    translated_hold_request['data']['nyplSource'] = 'sierra-nypl'

    $logger.info "Placing hold on virtual record #{virtual_record.item_id}"
    begin
      post_response = process_item_in_sierra(recap_hold_request, translated_hold_request)
      if post_response['code'] != '204' 
        raise 'hold request failed'
      end
      post_response
    rescue
        sierra_request = SierraRequest.new({})
        sierra_request.base_request_url = ENV['SIERRA_URL']
        sierra_request.assign_bearer
        $logger.info("Hold request #{recap_hold_request["trackingId"]} failed. Deleting associated OTF record #{virtual_record.bib_id}-#{virtual_record.item_id}")
        sierra_request.delete_record(virtual_record.item_id, 'item')
        sierra_request.delete_record(virtual_record.bib_id, 'bib')
    end
  end

  # Takes discovered hold request data and builds a valid Sierra requests out of the information provided.
  # Also retrieves pickup location code based on presence of pickupLocation or deliveryLocation.
  def self.build_new_sierra_request(hold_request_data)
    $logger.info "Processing Sierra NYPL Request: #{hold_request_data}"

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

  # Fetch holds by patron id via Sierra api
  def get_holds(patron)
    uri = URI.parse("#{self.base_request_url}/patrons/#{patron}/holds")
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{self.bearer}"

    req_options = {
      use_ssl: uri.scheme == "https",
      read_timeout: 500
    }

    begin
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
    rescue Exception => e
      $logger.error "Error communicating with host: #{uri.hostname}, port: #{uri.port}. Error: #{e.message}"
    end

    $logger.info "Header: #{response.header}, Body: #{response.body}"
    JSON.parse(response.body)
  end

end
