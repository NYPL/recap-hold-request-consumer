require 'spec_helper'

describe "initial test" do
  it "should know what truth is" do
    expect(true).to be true
  end
end

describe "authorization" do
  it "should return an authorization string" do
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

describe "sierra request" do
  suppressed_sierra_req                       = SierraRequest.new({"data" => {}})
  suppressed_sierra_req.delivery_location     = "NV"
  suppressed_sierra_req.base_request_url      = ENV['SIERRA_URL']
  suppressed_sierra_req.assign_bearer
  
  unsuppressed_sierra_req                     = SierraRequest.new({"data" => {}})
  unsuppressed_sierra_req.delivery_location   = "COOPER"
  unsuppressed_sierra_req.base_request_url    = ENV['SIERRA_URL']
  unsuppressed_sierra_req.assign_bearer

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
    sierra_res = SierraRequest.process_request({})
    expect(sierra_res["code"]).to eq("404")
  end

  it "should return 404 if passed garbage data or not enough data and is not suppressed" do
    sierra_res = SierraRequest.process_request({"data" => { "deliveryLocation" => "COOPER"}})
    expect(sierra_res["code"]).to eq("404")
    expect(unsuppressed_sierra_req.post_request.code).to eq("404") # because it's missing key ingredients
  end

  it "should return code from sierra request" do
    sierra_res = SierraRequest.process_request({"data" => { "deliveryLocation" => "NV"}},{"data" => {"patron" => "23338675309", "record" => "42", "pickupLocation" => "myf"}})
    expect(sierra_res["code"]).to eq("500") # Given the fake nature of the data, it shouldn't work. But at least it should get to the point of knowing that.
  end

  it "should automatically return 204 if suppressed" do
    sierra_res = SierraRequest.process_request({"data" => { "deliveryLocation" => "NV"}})
    expect(sierra_res["code"]).to eq("404") # when it can't actually find a matching hold request, it should be reported
    expect(suppressed_sierra_req.post_request).to eq("204") # if hold request vaild, by default it should be considered a success, no matter what.
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