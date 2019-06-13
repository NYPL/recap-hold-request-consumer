require 'spec_helper'

describe "requests" do
  it "should build an xml string when told to" do
    expect(AcceptItemRequest.new.respond_to?(:build_request_string)).to eq(true)
  end
end

describe "NCIP request" do
  valid_request = nil

  before :each do
    http = double
    allow(Net::HTTP).to receive(:start).and_yield http
    allow(http).to receive(:request).with(an_instance_of(Net::HTTP::Post))
        .and_return(Net::HTTPResponse)

    allow(HoldRequest).to receive(:get_bearer).and_return('supersecretbearertoken')
    allow(HoldRequest).to receive(:find).and_return({
      "id" => 25,
      "jobId" => "56599ecd3a5b438",
      "createdDate" => "2017-08-24T08:57:30-04:00",
      "updatedDate" => nil,
      "success" => false,
      "processed" => false,
      "patron" => "patronid",
      "nyplSource" => "sierra-nypl",
      "requestType" => "hold",
      "recordType" => "i",
      "record" => "10001136",
      "pickupLocation" => "mal",
      "deliveryLocation" => nil,
      "neededBy" => nil,
      "numberOfCopies" => nil,
      "docDeliveryData" => nil,
      "error" => nil
    })

    valid_request = AcceptItemRequest.new
  end

  it "should have a method to parse json data and post records" do
    expect(AcceptItemRequest.respond_to?(:process_request)).to eq(true)
  end

  it "should build an xml string and assign it to valid_request.request_string" do
    valid_request.build_request_string(23333102394119, Random.rand(10000000...19999999999), "lb", "blueRose430", "Dr \\ // <><><><????$$$%@@)()(#@...#@!$%^7$*&*) Jacoby", "Golden Shovels")
    expect(valid_request.request_string).to_not be_nil
  end

  it "should post a valid record to NCIP" do
    allow(Net::HTTPResponse).to receive(:code).and_return('200')
    allow(Net::HTTPResponse).to receive(:body)
      .and_return('the actual body of response')

    expect(valid_request.respond_to?(:post_record)).to eq(true)
    expect(valid_request.post_record["message"].scan("Problem")).to eq([])
  end

  it "should return nil for an invalid request string" do
    expect(AcceptItemRequest.process_request({})["code"]).to eq("404")
    expect(AcceptItemRequest.new.post_record["code"]).to eq("500")
  end

  it "should return success as false if request comes back with a problem" do
    expect(valid_request.post_record["code"]).to eq("500") # should already exist. 
  end
end
