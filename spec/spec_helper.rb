# code coverage
require 'simplecov'
SimpleCov.add_filter '/spec/'
SimpleCov.start

require 'benchmark'
require 'http'

# load libary
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'serpapi'

RSpec.configure do |config|
  config.include SerpApi

  config.before(:each) do
    ENV.key?('SERPAPI_KEY') || fail('Missing ENV SERPAPI_KEY')
  end
end

