require 'spec_helper'

describe "hold request" do
  let(:kinesis_mock) { instance_double(Aws::Kinesis::Client) }

  before :each do
    http = double
    allow(Net::HTTP).to receive(:start).and_yield http
    # Mock access_token:
    allow(HoldRequest).to receive(:get_bearer).and_return('supersecretbearertoken')
    allow(http).to receive(:request).and_return(Net::HTTPResponse)

    mock_kinesis_response = double
    allow(mock_kinesis_response).to receive(:successful?).and_return(true)
    allow(kinesis_mock).to receive(:put_record).and_return(mock_kinesis_response)

    allow(Aws::Kinesis::Client).to receive(:new).and_return(kinesis_mock)
  end

  it "should respond to a request for a specific hold request" do
    allow(Net::HTTPResponse).to receive(:code).and_return('200')
    allow(Net::HTTPResponse).to receive(:body)
      .and_return('{ }')

    expect(HoldRequest.find(921)).to_not be_nil
  end

  it "should send requests for partner item holds to ncip for temp record and hold creation" do
    allow(Net::HTTPResponse).to receive(:code).and_return('200')
    allow(Net::HTTPResponse).to receive(:body)
      .and_return('{ }')

    json_data = { "owningInstitutionId" => "pul" }
    hold_request = { "data" => "djfksdjfkjsdkjfsd" }
    expect(HoldRequest.new.route_request_with(json_data, hold_request, nil)["type"]).to eq("AcceptItemRequest")
  end

  it "should send requests for nypl item holds to sierra for hold creation" do
    allow(Net::HTTPResponse).to receive(:code).and_return('200')
    allow(Net::HTTPResponse).to receive(:body)
      .and_return('{ }')

    json_data = { "owningInstitutionId" => "nypl" }
    hold_request = { "data" => "djfksdjfkjsdkjfsd" }
    expect(HoldRequest.new.route_request_with(json_data, hold_request, nil)["type"]).to eq("SierraRequest")
  end
end
