# code coverage
require 'simplecov'
SimpleCov.start

require 'benchmark'
require 'http'

# load libary
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'serpapi'

RSpec.configure do |config|
  config.include SerpApi

  config.before(:each) do
    ENV.key?('API_KEY') || fail('Missing ENV API_KEY')
  end
end
