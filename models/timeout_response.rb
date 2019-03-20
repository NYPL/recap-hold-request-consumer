require 'json'
class TimeoutResponse
  def initialize
  end

  def code
    "500"
  end

  def body
    {"description" => "Timeout"}.to_json
  end
end
