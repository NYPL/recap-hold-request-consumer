require 'spec_helper'

describe "custom_logger" do
  it "should respond to accessor methods" do 
    # :level, :message, :level_code, :error_codename, :timestamp
    new_log = CustomLogger.new({})
    expect(new_log.respond_to?(:message)).to eq(true)
    expect(new_log.respond_to?(:level)).to eq(true)
    expect(new_log.respond_to?(:timestamp)).to eq(true)
    expect(new_log.respond_to?(:error_codename)).to eq(true)
    expect(new_log.respond_to?(:level_code)).to eq(true)
  end
  
  it "should generate an error if required fields are not found" do
    new_log = CustomLogger.new({"level" => "info"})
    expect(new_log.validity_report).to eq([false, "Missing required fields: message"])
    expect(new_log.valid?).to eq(false)
  end

  it "should generate an error if given an unrecognizable level" do 
    new_log = CustomLogger.new({"level" => "13th Floor", "message" => "Who goes there?"})
    expect(new_log.validity_report).to eq([false, "Invalid level. "])
    expect(new_log.valid?).to eq(false)
  end

  it "should generate a json-formatted string if presented with the proper fields" do
    new_log = CustomLogger.new({"level" => "error", "message" => "not enough coffee"})
    expect(new_log.log_message).to eq(true)
  end

  it "should format timestamp according to iso8601 standard" do 
    new_log = CustomLogger.new({"level" => "debug", "message" => "made more coffee"})
    this_time = Time.now
    new_log.timestamp = this_time
    new_log.reformat_fields
    expect(new_log.timestamp).to eq(this_time.to_time.iso8601)
  end

  it "should assign the appropriate error level code" do
    new_log = CustomLogger.new({"level" => "info", "message" => "those shoes are fabulous"})
    new_log.reformat_fields
    expect(new_log.level_code).to eq(6)
  end

  it "should upcase all level strings just in case" do 
    new_log = CustomLogger.new({"level" => "info", "message" => "and your hair, too!"})
    new_log.reformat_fields
    expect(new_log.level).to eq("INFO")
  end

end