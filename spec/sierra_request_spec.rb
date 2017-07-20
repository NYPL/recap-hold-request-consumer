require 'spec_helper'

describe "initial test" do
  it "should know what truth is" do
    expect(true).to be true
  end
end

describe "authorization" do
  it "should return an authorization string" do
    expect(SierraRequest.get_bearer).to_not be_nil
  end
end

describe "sierra request" do
  suppressed_sierra_req     = SierraRequest.new({"data" => { "deliveryLocation" => "NV"}})
  unsuppressed_sierra_req   = SierraRequest.new({"data" => { "deliveryLocation" => "COOPER"}})

  it "should check for suppression" do
    expect(suppressed_sierra_req.respond_to?(:suppressed?)).to eq(true)
  end

  it "should return true if code matches suppressed codes" do
    expect(suppressed_sierra_req.suppressed?).to eq(true)
  end

  it "should return false if code does not match suppressed codes" do
    expect(unsuppressed_sierra_req.suppressed?).to eq(false)
  end

  it "should post json message to sierra" do
    expect(SierraRequest.respond_to?(:process_request)).to eq(true)
    expect(suppressed_sierra_req.respond_to?(:post_request)).to eq(true)
    expect(suppressed_sierra_req.post_request).to eq("204") # because by default it should be considered a success, no matter what. 
  end

  it "should return 404 if passed garbage data or not enough data and is not suppressed" do
    expect(unsuppressed_sierra_req.post_request).to eq("404") # because it's missing key ingredients
  end

  it "should automatically return 204 if suppressed" do
    expect(suppressed_sierra_req.post_request).to eq("204") # because by default it should be considered a success, no matter what.
  end
end