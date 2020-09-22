require 'simplecov'
require 'dotenv'
require 'webmock/rspec'

Dotenv.load('./config/var_test.env')

SimpleCov.start do
  add_filter 'test/'
  add_filter 'config/'
  add_filter 'vendor/'
  add_filter 'ruby/'
  add_filter 'spec/'
end unless ENV['TRAVIS'] # Frequently crashes in travis-ci

require 'require_all'
require_all 'models'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
