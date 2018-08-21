# Custom logging model used for building the log messages for CloudWatch monitoring.
class CustomLogger
  attr_accessor :level, :message, :level_code, :error_codename, :timestamp

  VALID_LEVELS = { 'DEBUG' => 7,
                   'INFO' => 6,
                   'NOTICE' => 5,
                   'WARNING' => 4,
                   'ERROR' => 3,
                   'CRITICAL' => 2,
                   'ALERT' => 1,
                   'EMERGENCY' => 0 }

  # Creates a customer logger given a hash.
  # Right now, message and level are required, and level must be included in the keys of VALID_LEVELS
  def initialize(hash)
    hash.keys.each do |key|
      m = "#{key}="
      self.send( m, hash[key] ) if self.respond_to?( m )
    end

    self.timestamp = Time.now if self.timestamp == nil
  end

  # Returns array where first element is true or false, depending on validity of log message.
  # Second value reports what's missing.
  def validity_report
    return_array = [true, ""]

    if self.level == nil || VALID_LEVELS.keys.include?(self.level.upcase) == false
      return_array[0] = false
      return_array[1] += "Invalid level. "
    end

    if self.level == nil || self.message == nil || self.timestamp == nil
      return_array[0] = false
      return_array[1] += "Missing required fields: "
      return_array_missing_fields = []
      return_array_missing_fields << "level" if self.level == nil || VALID_LEVELS.keys.include?(self.level.upcase) == false
      return_array_missing_fields << "message" if self.message == nil
      return_array_missing_fields << "timestamp" if self.timestamp == nil
      return_array[1] += return_array_missing_fields.join(', ')
    end

    return_array
  end

  # Returns the boolean value of the validity report, being true or false.
  def valid?
    validity_report[0]
  end

  # Formats the values of level and timestamp and auto-generates level code based on level.
  def reformat_fields
    self.level = self.level.upcase
    self.level_code = VALID_LEVELS[self.level]
    self.timestamp = self.timestamp
  end

  # If valid, log_message will log JSON to Cloudwatch logs and return 'true', else will return 'false'.
  def log_message
    return valid? if valid? == false
    formatted_message = self.reformat_fields
    json_message = JSON.generate(level: self.level,
                                 message: self.message,
                                 levelCode: self.level_code,
                                 errorCodename: self.error_codename,
                                 timestamp: self.timestamp)
    puts json_message
    return true
  end

end
