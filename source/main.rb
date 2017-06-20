#!/usr/bin/env ruby
require 'aws-sdk'
require 'aws/kclrb'
require 'json'
require_relative 'models/accept_item_request.rb'

config = File.read('config.json')
config_hash = JSON.parse(config)

Aws.config.update({
  credentials: Aws::Credentials.new(config_hash['ACCESS_KEY_ID'], config_hash['SECRET_ACCESS_KEY'])
})

s3 = Aws::S3::Resource.new(region: 'us-east-1')
s3.buckets.each do |b|
  puts "#{b.name}"
end

accept_item_request = AcceptItemRequest.new

puts "Hello, from Ruby."