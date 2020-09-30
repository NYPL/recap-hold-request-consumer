class SierraApiError < StandardError
  def initialize(msg="Sierra API Error")
    super
  end
end

class SierraVirtualRecordError < SierraApiError
  def initialize(msg="Sierra Virtual Record Error")
    super
  end
end
