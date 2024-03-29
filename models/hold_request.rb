# Model representing a hold request in a general sense.
# Refers to a hold request that has an entry in the postgres database and which has information retrievable via API.
# Can be either an NYPL hold or a partner library hold.
class HoldRequest
  require 'json'
  require 'net/http'
  require 'uri'

  # Obtains authorization for the request.
  def self.get_bearer
    uri = URI.parse(ENV['RECAP_HOLD_REQUEST_AUTH_URL'])
    request = Net::HTTP::Post.new(uri)

    request.basic_auth(ENV['RECAP_CLIENT_ID'], Kms.decrypt(ENV['ENCODED_RECAP_CLIENT_SECRET']))

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

  # Looks up a hold requests via API.
  def self.find(hold_request_id)
    uri = URI.parse("#{ENV['PLATFORM_API_BASE_URL']}/hold-requests/#{hold_request_id}")
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/json"
    request["Accept"] = "application/json"
    request["Authorization"] = "Bearer #{self.get_bearer}"

    req_options = {
      use_ssl: uri.scheme == "https"
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    if response.code == "200"
      JSON.parse(response.body)
    else
      response.code
    end
  end

  # Handles the parsing of the hold request.
  # Routes hold requests to post to NCIP if request is a partner hold.
  # Routes hold requests to post to Sierra holds if request is an NYPL hold.
  def route_request_with(event_data, hold_request, timestamp)
    owner = ""

    if event_data == nil || event_data.count == 0 || event_data["owningInstitutionId"] == nil
      $logger.error "Request data missing key information. Cannot proceed. Malformed request. #{event_data}"
    else
      owner = event_data["owningInstitutionId"].downcase
    end

    if owner.scan('nypl').empty?
      $logger.info "Processing partner hold"

      response = SierraRequest.process_partner_item(event_data)

      RequestResult.process_response(response, 'AcceptItemRequest', event_data, hold_request, timestamp)

    elsif owner != ""
      $logger.info "Processing NYPL hold"

      response = SierraRequest.process_nypl_item(event_data)

      RequestResult.process_response(response, 'SierraRequest', event_data, hold_request, timestamp)
    end
  end
end
