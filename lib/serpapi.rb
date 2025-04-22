# Ruby client for SerpApi.com
#  Scrape results for all major search engines from our fast, easy, and complete API.
module SerpApi
  # see serpapi for implementation
end

# load faraday HTTP lib
require 'faraday'

# load
require 'json'

# implementation
require_relative 'serpapi/version'
require_relative 'serpapi/error'
require_relative 'serpapi/client'
