require 'spec_helper'

describe "location" do
  before :each do
    allow(Net::HTTP).to receive(:get_response).and_return(Net::HTTPResponse)
  end

  it "should return a pickup location if given a valid code" do
    allow(Net::HTTPResponse).to receive(:body)
      .and_return(File.read('./spec/fixtures/nypl-core-by_recap_customer_code.json'))

    code = Location.get_pickup_for("NV")
    expect(code).to eq("myf")
  end

  it "should return nil if given a bad code" do
    code = Location.get_pickup_for("garmonbozia")
    expect(code).to be_nil
  end
end
