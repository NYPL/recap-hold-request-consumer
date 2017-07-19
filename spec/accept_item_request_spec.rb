require 'spec_helper'

describe "requests" do
  it "should build an xml string when told to" do
    expect(AcceptItemRequest.new.respond_to?(:build_request_string)).to eq(true)
  end
end

describe "NCIP request" do
  it "should have a method to parse json data and post records" do
    expect(AcceptItemRequest.respond_to?(:process_request)).to eq(true)
  end
  
  valid_request = AcceptItemRequest.new 

  it "should build an xml string and assign it to valid_request.request_string" do
    valid_request.build_request_string(234567890987654, Random.rand(10000000...19999999999), "lb", "blueRose430", "Dr Jacoby", "Golden Shovels")
    expect(valid_request.request_string).to_not be_nil
  end

  it "should post a valid record to NCIP" do
    expect(valid_request.respond_to?(:post_record)).to eq(true)
    expect(valid_request.post_record.scan("Problem")).to eq([])
  end
end
