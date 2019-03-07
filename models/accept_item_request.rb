# Model responsible for building a posting a temp record to NCIP.
class AcceptItemRequest
  require 'json'
  require 'net/http'
  require 'uri'
  require_relative 'custom_logger.rb'
  require_relative 'location.rb'
  require_relative 'kms.rb'
  attr_accessor :request_string

  # Pulls apart information from json_data hash (retrieved from Kinesis event),
  # then sends the information to the build request process to format in XML.
  # Once XML is built, posts temp record to NCIP.
  def self.process_request(json_data, hold_request = nil)
    p [15, hold_request]
    hold_request    = hold_request || HoldRequest.find(json_data["trackingId"])

    return {"code" => "404", "message" => "missing hold request data" } if hold_request["data"] == nil
    return {"code" => "500", "message" => "missing item description data" } if json_data["description"] == nil

    hold_data       = hold_request["data"]
    borrowerId      = json_data["patronBarcode"]
    itemBarcode     = json_data["itemBarcode"]

    if hold_data["pickupLocation"] != nil && hold_data["pickupLocation"] != [] && hold_data["pickupLocation"] != ""
      pickupLocation  = hold_data["pickupLocation"]
    else
      pickupLocation = Location.get_pickup_for(hold_data["deliveryLocation"])
    end

    callNumber      = json_data["description"]["callNumber"]
    author          = json_data["description"]["author"]
    title           = json_data["description"]["title"]

    new_request     = AcceptItemRequest.new

    # default 23333102394119
    new_request.build_request_string(borrowerId, itemBarcode, pickupLocation, callNumber, author, title)
    result = new_request.post_record
  end

  # Takes key information and plugs it into an NCIP XML Message.
  def build_request_string(borrowerId, itemBarcode, pickupLocation, callNumber, author, title)
    string = %{<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <NCIPMessage version="http://www.niso.org/schemas/ncip/v2_0/ncip_v2_0.xsd" xmlns="http://www.niso.org/2008/ncip">
          <AcceptItem>
              <RequestId>
                  <AgencyId>Relais</AgencyId>
                  <RequestIdentifierType>Barcode Id</RequestIdentifierType>
                  <RequestIdentifierValue>007</RequestIdentifierValue>
              </RequestId>
              <RequestedActionType>Hold For Pickup</RequestedActionType>
              <UserId>
                  <AgencyId>main</AgencyId>
                  <UserIdentifierType>Primary Key</UserIdentifierType>
                  <UserIdentifierValue>b#{borrowerId}</UserIdentifierValue>
              </UserId>
              <ItemId>
                  <AgencyId>main</AgencyId>
                  <ItemIdentifierType>Barcode Id</ItemIdentifierType>
                  <ItemIdentifierValue>#{itemBarcode}</ItemIdentifierValue>
              </ItemId>
              <ItemOptionalFields>
                  <BibliographicDescription>
                      <Author>#{AcceptItemRequest.escape_characters_in_string(author)}</Author>
                      <Title>#{AcceptItemRequest.escape_characters_in_string(title)}</Title>
                  </BibliographicDescription>
                  <ItemDescription>
                      <CallNumber>#{callNumber}</CallNumber>
                  </ItemDescription>
              </ItemOptionalFields>
              <PickupLocation>#{pickupLocation}</PickupLocation>
          </AcceptItem>
      </NCIPMessage>}
    CustomLogger.new({ "level" => "INFO", "message" => "Contructed XML string: #{string}"}).log_message
    self.request_string = string
  end

  # need to escape anything unescaped
  def self.escape_characters_in_string(string)
    pattern = /(\'|\"|\.|\*|\/|\-|\\|\)|\$|\+|\(|\^|\?|\!|\~|\`)/
    string.gsub(pattern){|match|"\\"  + match}.encode(:xml => :text)
  end

  # Posts the XML record to Sierra NCIP. Returns code and message.
  def post_record
    if request_string != nil
      require 'net/http'
      require 'uri'

      uri = URI.parse(ENV['NCIP_URL'])
      request = Net::HTTP::Post.new(uri)
      request.content_type = "application/xml"
      request.body = request_string

      req_options = {
        use_ssl: uri.scheme == "https",
        read_timeout: 500
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      CustomLogger.new({ "level" => "INFO", "message" => "#{response.body}"}).log_message

      problem = response.body.scan("Problem")
      if response.code != "200" || problem.join(',').length != 0
        code = "500"
      else
        code = "200"
      end

      { "code" => code, "message" => response.body }
    else
      CustomLogger.new({ "level" => "WARNING", "message" => "ncip request string blank"}).log_message
      { "code" => "500", "message" => "ncip request string blank" }
    end
  end

end
