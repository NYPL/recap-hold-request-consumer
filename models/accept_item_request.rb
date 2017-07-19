class AcceptItemRequest
  require 'json'
  require 'net/http'
  require 'uri'

  attr_accessor :request_string

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
                      <Author>#{author}</Author>
                      <Title>#{title}</Title>
                  </BibliographicDescription>
                  <ItemDescription>
                      <CallNumber>#{callNumber}</CallNumber>
                  </ItemDescription>
              </ItemOptionalFields>
              <PickupLocation>#{pickupLocation}</PickupLocation>
          </AcceptItem>
      </NCIPMessage>}
    self.request_string = string
  end

  def self.process_request(json_data)
    hold_request    = HoldRequest.find(json_data["id"])
    hold_data       = hold_request["data"]
    borrowerId      = hold_data["patron"]
    itemBarcode     = hold_data["record"]
    pickupLocation  = hold_data["pickupLocation"]
    
    callNumber      = json_data["description"]["callNumber"]
    author          = json_data["description"]["author"]
    title           = json_data["description"]["title"]
    
    new_request     = AcceptItemRequest.new
    new_request.build_request_string(borrowerId, itemBarcode, pickupLocation, callNumber, author, title)
    result = new_request.post_record
  end

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
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      res = response.body
    else
      res = nil
    end
    res
  end

end
