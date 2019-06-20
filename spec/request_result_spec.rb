require 'spec_helper'
require_relative '../models/request_result.rb'

request_denied_hash = {"code"=>"500",
  "message"=>"{\"code\":132,\"specificCode\":2,\"httpStatus\":500,\"name\":\"XCirc error\",\"description\":\"XCirc error : Request denied - already on hold for or checked out to you.\"}"
}

already_sent_hash = {"code"=>"500",
  "message"=>"{\"code\":132,\"specificCode\":2,\"httpStatus\":500,\"name\":\"XCirc error\",\"description\":\"XCirc error : Your request has already been sent.\"}"
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
  end
end
