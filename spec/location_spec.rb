require 'spec_helper'

describe "location" do
  it "should return a pickup location if given a valid code" do
    code = Location.get_pickup_for("NV")
    expect(code).to eq("myf")
  end

  it "should return nil if given a bad code" do
    code = Location.get_pickup_for("garmonbozia")
    expect(code).to be_nil
  end
end
