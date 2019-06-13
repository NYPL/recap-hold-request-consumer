require 'spec_helper'

describe "initial test" do
  it "should know what truth is" do
    expect(true).to be true
  end
end

describe "authorization" do
  before :each do
    allow(Kms).to receive(:decrypt).and_return('decryptedvalue')
  end

  it "should return an authorization string" do
    http = double
    allow(Net::HTTP).to receive(:start).and_yield http
    allow(http).to receive(:request).and_return(Net::HTTPResponse)
    allow(Net::HTTPResponse).to receive(:code).and_return('200')
    allow(Net::HTTPResponse).to receive(:body)
      .and_return('{ "access_token": "accesstokenforimportantthings" }')

    new_sierra_request = SierraRequest.new({})
    new_sierra_request.base_request_url = ENV['SIERRA_URL']
    new_sierra_request.assign_bearer
    expect(new_sierra_request.bearer).to_not be_nil
  end

  it "should gracefully fail" do 
    new_sierra_request = SierraRequest.new({})
    new_sierra_request.base_request_url = ENV['MOCKY_TIMEOUT_URL']
    new_sierra_request.assign_bearer
    expect(new_sierra_request.bearer).to be_nil

    new_sierra_request.base_request_url = ENV['MOCKY_404_URL']
    new_sierra_request.assign_bearer
    expect(new_sierra_request.bearer).to be_nil

    new_sierra_request.base_request_url = ENV['MOCKY_500_URL']
    new_sierra_request.assign_bearer
    expect(new_sierra_request.bearer).to be_nil

    new_sierra_request.base_request_url = {}
    new_sierra_request.assign_bearer
    expect(new_sierra_request.bearer).to be_nil
  end
end

describe SierraRequest do
  suppressed_sierra_req = nil
  unsuppressed_sierra_req = nil
  
  before :each do
    http = double
    allow(Net::HTTP).to receive(:start).and_yield http
    allow(http).to receive(:request).and_return(Net::HTTPResponse)

    allow(Kms).to receive(:decrypt).and_return('decryptedvalue')

    suppressed_sierra_req = SierraRequest.new({"data" => {}})
    suppressed_sierra_req.delivery_location     = "NV"
    suppressed_sierra_req.base_request_url      = ENV['SIERRA_URL']
    suppressed_sierra_req.assign_bearer

    unsuppressed_sierra_req                     = SierraRequest.new({"data" => {}})
    unsuppressed_sierra_req.delivery_location   = "COOPER"
    unsuppressed_sierra_req.base_request_url    = ENV['SIERRA_URL']
    unsuppressed_sierra_req.assign_bearer
  end

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
  end

  it "should gracefully fail if given no data" do 
    # Anticipate process_request will attempt to fetch hold data by [non-existant] trackingId:
    allow(Net::HTTPResponse).to receive(:code).and_return('200')
    allow(Net::HTTPResponse).to receive(:body)
      .and_return('{}')

    sierra_res = SierraRequest.process_request({})
    expect(sierra_res["code"]).to eq("404")
  end

  it "should return 404 if passed garbage data or not enough data and is not suppressed" do
    # Anticipate process_request will attempt to fetch hold data by [non-existant] trackingId:
    allow(Net::HTTPResponse).to receive(:code).and_return('404')
    allow(Net::HTTPResponse).to receive(:body)
      .and_return('{}')

    sierra_res = SierraRequest.process_request({"data" => { "deliveryLocation" => "COOPER"}})
    expect(sierra_res["code"]).to eq("404")
    expect(unsuppressed_sierra_req.post_request.code).to eq("404") # because it's missing key ingredients
  end

  it "should return code from sierra request" do
    # We anticipate that this will build a SierraRequest object with:
    #  @json_body={"patron"=>"23338675309", "record"=>"42", "pickupLocation"=>"myf"}
    #  @delivery_location=nil
    #  @base_request_url="https://example.com"
    #  @patron_id="23338675309"
    #  @record_number="42"
    #  @pickup_location="myf"
    # Which will be posted to Sierra api as:
    #  "{\"recordType\":\"i\",\"recordNumber\":42,\"pickupLocation\":\"myf\"}"
    # We anticipate the Sierra API responding to the nonsensical record number '42' with http status 500
    allow(Net::HTTPResponse).to receive(:code).and_return('500')
    allow(Net::HTTPResponse).to receive(:body)
      .and_return('{}')

    sierra_res = SierraRequest.process_request({"data" => { "deliveryLocation" => "NV"}}, {"data" => {"patron" => "23338675309", "record" => "42", "pickupLocation" => "myf"}})
    expect(sierra_res["code"]).to eq("500") # Given the fake nature of the data, it shouldn't work. But at least it should get to the point of knowing that.
  end

  ['BD', 'NV', 'OI'].each do |location|
    it "should automatically return 204 if suppressed deliveryLocation '#{location}'" do
      # Build a fake hold-request instance (so that process_request doesn't
      # attempt to fetch it itself via [nonexistant] trackingId)::
      hold_request_data = {
        "data" => {
          "patron" => "1234",
          "record" => "5678",
          "deliveryLocation" => location
        }
      }
      # Normally first param (json_data) would include trackingId, but it's not
      # needed if we're passing in hold_request instance in second param:
      sierra_res = SierraRequest.process_request({}, hold_request_data)
      # Note no http mocking required because code immediately returns success
      # based on suppressed delivery location code:
      expect(sierra_res["code"]).to eq("204")
    end
  end

  it "should build a valid sierra request if given appropriate data" do
    hold_request_data = {"patron" => "23338675309", "record" => "42", "deliveryLocation" => "NV"}

    new_sierra_request = SierraRequest.build_new_sierra_request(hold_request_data)
    expect(new_sierra_request).to_not be(nil)
    expect(new_sierra_request.patron_id).to eq(hold_request_data["patron"])
    expect(new_sierra_request.record_number).to eq(hold_request_data["record"])
    expect(new_sierra_request.delivery_location).to eq(hold_request_data["deliveryLocation"])
    expect(new_sierra_request.pickup_location).to eq(Location.get_pickup_for("NV"))
  end

  it "should build a sierra request with the provided pickup location if it is provided" do
    hold_request_data = {"patron" => "23338675309", "record" => "42", "pickupLocation" => "myf"}
    new_sierra_request = SierraRequest.build_new_sierra_request(hold_request_data)

    expect(new_sierra_request).to_not be(nil)
    expect(new_sierra_request.patron_id).to eq(hold_request_data["patron"])
    expect(new_sierra_request.record_number).to eq(hold_request_data["record"])
    expect(new_sierra_request.delivery_location).to eq(hold_request_data["deliveryLocation"])
    expect(new_sierra_request.pickup_location).to eq("myf")
  end

  it "should not be fooled by blank values in the pickup location" do 
    hold_request_data = {"patron" => "23338675309", "record" => "42", "pickupLocation" => "", "deliveryLocation" => "NV"}
    new_sierra_request = SierraRequest.build_new_sierra_request(hold_request_data)

    expect(new_sierra_request).to_not be(nil)
    expect(new_sierra_request.patron_id).to eq(hold_request_data["patron"])
    expect(new_sierra_request.record_number).to eq(hold_request_data["record"])
    expect(new_sierra_request.delivery_location).to eq(hold_request_data["deliveryLocation"])
    expect(new_sierra_request.pickup_location).to eq(Location.get_pickup_for("NV"))
  end
end

# Tests using Mocky:
describe SierraRequest do
  before :each do
    allow(Kms).to receive(:decrypt).and_return('decryptedvalue')
  end

  it "should gracefully fail if requests to sierra return bad responses" do
    hold_request_data = {"patron" => "23338675309", "record" => "42", "pickupLocation" => "myf"}
    bad_sierra_request = SierraRequest.build_new_sierra_request(hold_request_data)
    bad_sierra_request.assign_bearer

    bad_sierra_request.base_request_url = ENV['MOCKY_TIMEOUT_URL']
    expect(bad_sierra_request.post_request.code).to eq("408")

    bad_sierra_request.base_request_url = ENV['MOCKY_404_URL']
    expect(bad_sierra_request.post_request.code).to eq("404")

    bad_sierra_request.base_request_url = ENV["MOCKY_500_URL"]
    expect(bad_sierra_request.post_request.code).to eq("500")
  end
end
