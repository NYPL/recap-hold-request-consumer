class HoldRequest
  require 'json'
  require 'net/http'
  require 'uri'

  def self.get_bearer
    uri = URI.parse(ENV['RECAP_HOLD_REQUEST_AUTH_URL'])
    request = Net::HTTP::Post.new(uri)
    request.basic_auth(ENV['RECAP_CLIENT_ID'], ENV['RECAP_CLIENT_SECRET'])
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

  def self.find(hold_request_id, iteration=0)
    uri = URI.parse("#{ENV['HOLD_REQUESTS_URL']}/hold-requests/#{hold_request_id}")
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

  def self.list
    uri = URI.parse("#{ENV['HOLD_REQUESTS_URL']}/hold-requests")
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

    JSON.parse(response.body)
  end
end
