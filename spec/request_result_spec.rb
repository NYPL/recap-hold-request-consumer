require 'spec_helper'
require_relative '../models/request_result.rb'

request_denied_hash = {"code"=>"500",
  "message"=>"{\"code\":132,\"specificCode\":2,\"httpStatus\":500,\"name\":\"XCirc error\",\"description\":\"XCirc error : Request denied - already on hold for or checked out to you.\"}"
}

already_sent_hash = {"code"=>"500",
  "message"=>"{\"code\":132,\"specificCode\":2,\"httpStatus\":500,\"name\":\"XCirc error\",\"description\":\"XCirc error : Your request has already been sent.\"}"
}

describe "initial test" do
  it "should know what truth is" do
    expect(true).to be true
  end
end

describe "already_sent_error?" do
  it "should check if the error type is 'already sent'" do
    expect(RequestResult.already_sent_error?(request_denied_hash)).to be false
    expect(RequestResult.already_sent_error?(already_sent_hash)).to be true
  end
end
