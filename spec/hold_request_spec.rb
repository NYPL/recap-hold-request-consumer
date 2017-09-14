require 'spec_helper'

describe "hold request" do
  it "should respond to a request for a specific hold request" do
    expect(HoldRequest.find(921)).to_not be_nil
  end

  it "should send requests for partner item holds to ncip for temp record and hold creation" do
    json_data = { "owningInstitutionId" => "pul" }
    hold_request = { "data" => "djfksdjfkjsdkjfsd" }
    expect(HoldRequest.new.route_request_with(json_data,hold_request)["type"]).to eq("AcceptItemRequest")
  end

  it "should send requests for nypl item holds to sierra for hold creation" do
    json_data = { "owningInstitutionId" => "nypl" }
    hold_request = { "data" => "djfksdjfkjsdkjfsd" }
    expect(HoldRequest.new.route_request_with(json_data,hold_request)["type"]).to eq("SierraRequest")
  end
end