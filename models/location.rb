# Model for finding pickup locations if given delivery codes.
class Location

  # Gets the pickup code for a given delivery code.
  def self.get_pickup_for(recap_delivery_code)
    require 'net/http'
    require 'uri'
    begin
      uri = URI.parse(ENV['LOCATIONS_URL'])
      response = Net::HTTP.get_response(uri)
      loc_hash = JSON.parse(response.body)
      if loc_hash[recap_delivery_code] && loc_hash[recap_delivery_code]["sierraLocation"] && loc_hash[recap_delivery_code]["sierraLocation"]["code"]
        loc_hash[recap_delivery_code]["sierraLocation"]["code"]
      else
        $logger.warn "Unable to find pickup location for #{recap_delivery_code}"
        nil
      end
    rescue Exception => e
      $logger.warn "Unable to find pickup location for #{recap_delivery_code}"
      nil
    end
  end

end
