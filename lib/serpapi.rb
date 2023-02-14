# Ruby client for SerpApi.com
#  Scrape results for all major search engines from our fast, easy, and complete API.
module SerpApi
  # see serpapi/serpapi for implementation
end

# load native ruby dependency
require 'open-uri'
require 'json'

# implementation
require_relative 'serpapi/error'
require_relative 'serpapi/serpapi'
