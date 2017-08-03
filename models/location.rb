class Location

  def self.get_pickup_for(recap_delivery_code)
    require 'net/http'
    require 'uri'
    uri = URI.parse("https://nypl-core-objects-mapping-qa.s3.amazonaws.com/by_recap_customer_code.json")
    response = Net::HTTP.get_response(uri)
    loc_hash = JSON.parse(response.body)
    if loc_hash[recap_delivery_code] && loc_hash[recap_delivery_code]["sierraLocation"] && loc_hash[recap_delivery_code]["sierraLocation"]["code"]
      loc_hash[recap_delivery_code]["sierraLocation"]["code"]
    else
      CustomLogger.new({ "level" => "WARNING", "message" => "Unable to find pickup location for #{recap_delivery_code}"}).log_message
      nil
    end
  end

end
