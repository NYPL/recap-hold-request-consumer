require 'spec_helper'
require_relative '../models/request_result.rb'

request_denied_hash = {"code"=>"500",
  "message"=>"{\"code\":132,\"specificCode\":2,\"httpStatus\":500,\"name\":\"XCirc error\",\"description\":\"XCirc error : Request denied - already on hold for or checked out to you.\"}"
}

already_sent_hash = {"code"=>"500",
  "message"=>"{\"code\":132,\"specificCode\":2,\"httpStatus\":500,\"name\":\"XCirc error\",\"description\":\"XCirc error : Your request has already been sent.\"}"
}

suppressed_item_hash = {"code"=>"500",
  "message"=>"{\"code\":132, \"specificCode\":2, \"httpStatus\":500, \"name\": \"XCirc error\", \"description\": \"XCirc error : This record is not available\"}"
}

describe RequestResult do
  describe "is_error_type?" do
    before :each do
      mock_sierra_client = instance_double(SierraRequest)
      allow(SierraRequest).to receive(:new).and_return(mock_sierra_client)
      allow(mock_sierra_client).to receive(:base_request_url=)
      allow(mock_sierra_client).to receive(:assign_bearer)
      allow(mock_sierra_client).to receive(:get_holds).and_return(File.read('./spec/fixtures/sierra-patron-holds.json'))
    end

    it "should identify request-denied-already-on-hold as 'already sent' error" do
      expect(RequestResult.is_error_type?(request_denied_hash, RequestResult.already_sent_errors)).to be true
    end

    it "should not identify error with phrase \"Your request has already been sent.\" as an 'already sent' error" do
      expect(RequestResult.is_error_type?(already_sent_hash, RequestResult.already_sent_errors)).to be false
    end

    it "should identify \"Your request has already been sent.\" as a retryable error" do
      expect(RequestResult.is_error_type?(already_sent_hash, RequestResult.retryable_errors)).to be true
    end

    it "should identify suppressed item message as an error" do
      expect(RequestResult.is_error_type?(suppressed_item_hash, RequestResult.possible_item_suppressed_errors)).to be true
    end
  end

  describe "process_response" do
    let(:kinesis_mock) { instance_double(Aws::Kinesis::Client) }

    before do
      # Route Kinesis writes to a mock
      mock_kinesis_response = double
      allow(mock_kinesis_response).to receive(:successful?).and_return(true)
      allow(kinesis_mock).to receive(:put_record).and_return(mock_kinesis_response)
      allow(Aws::Kinesis::Client).to receive(:new).and_return(kinesis_mock)
    end

    it "should handle hold failures at staff-only locations as successes" do
      json_data = { "trackingId" => "hold-request-id" }
      hold_request = { "data" => { "jobId" => "job-id", "deliveryLocation" => "NV" } }
      result = RequestResult.process_response(suppressed_item_hash, 'SierraRequest', json_data, hold_request)

      expect(result).to be_a(Hash)
      expect(result['code']).to eq('200')
    end

    it "should handle hold failures at public facing locations as failures" do
      json_data = { "trackingId" => "hold-request-id" }
      hold_request = { "data" => { "jobId" => "job-id", "deliveryLocation" => "NH" } }
      result = RequestResult.process_response(suppressed_item_hash, 'SierraRequest', json_data, hold_request)

      expect(result).to be_a(Hash)
      expect(result['code']).to eq('500')
    end
  end
end
