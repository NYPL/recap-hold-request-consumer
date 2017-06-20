class AcceptItemRequest
  require 'nokogiri'
  require 'faraday'
  require 'faraday_middleware'
  require 'json'

  config = File.read('config.json')
  config_hash = JSON.parse(config)

  NCIP_URL = config_hash["NCIP_URL"]  # 'https://nypl-sierra-test.iii.com/iii/nciprelais/Restful'

  def initialize
    xml = example_request
    require 'pry';binding.pry;
  end

  def example_request
    borrowerId = 1
    itemBarcode = 1
    author = 'Baron von Groovy'
    title = 'The Periwinkle Twilight of Baron von Starshine'
    callNumber = 'Blondie-8675309'
    pickupLocation = 'Frontage Road, Moving Fast'
    string = %{<?xml version="1.0" encoding="UTF-8" standalone="yes"?><NCIPMessage version="http://www.niso.org/schemas/ncip/v2_0/ncip_v2_0.xsd" xmlns="http://www.niso.org/2008/ncip">
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
            <UserIdentifierValue>b234567890987654</UserIdentifierValue>
        </UserId>
        <ItemId>
            <AgencyId>main</AgencyId>
            <ItemIdentifierType>Barcode Id</ItemIdentifierType>
            <ItemIdentifierValue>#{Random.rand(3210107593764798979109202..9910107593764798979109202)}</ItemIdentifierValue>
        </ItemId>
        <ItemOptionalFields>
            <BibliographicDescription>
                <Author>Penrose, Barrie.   </Author>
                <Title>[No Restrictions] STALIN'S GOLD : THE STORY OF HMS EDINBURGH AND ITS TREASURE /       [RECAP]</Title>
            </BibliographicDescription>
            <ItemDescription>
                <CallNumber></CallNumber>
            </ItemDescription>
        </ItemOptionalFields>
        <PickupLocation>lb</PickupLocation>
    </AcceptItem></NCIPMessage>}
    Nokogiri::XML(string)
  end

  def post_message
    acceptItemURL = NCIP_URL
    new_request = AcceptItemRequest.new.to_s
    conn = Faraday.new(url: acceptItemURL) do |builder|
      builder.response :logger
      builder.use Faraday::Adapter::NetHttp
    end

    res = conn.post do |request|
      request.url acceptItemURL
      request.body = new_request
    end

    res.body
  end

end
