require 'simplecov'
require 'dotenv'

Dotenv.load('.env', 'var_app', './config/var_app')

SimpleCov.start do
  add_filter 'test/'
  add_filter 'config/'
  add_filter 'vendor/'
  add_filter 'ruby/'
  add_filter 'spec/'
end

require 'require_all'
require_all 'models'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
