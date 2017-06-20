require 'spec_helper'

describe "stream" do
    it should "respond to basic methods" do
        stream = Stream.new
        expect(stream.responds_to?(avro_decode)).to eq(true)
        expect(stream.responds_to?(raw_response)).to eq(true)
    end
end