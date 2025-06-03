# This script initializes default parameters for interacting with the SerpApi service.
# The `default_params` hash contains the following keys:
# - `engine`: Specifies the search engine to be used, in this case, 'google'.
# - `api_key`: Retrieves the API key from the environment variable `SERPAPI_KEY`.
# Ensure that the `SERPAPI_KEY` environment variable is set before running this script.

raise 'SERPAPI_KEY environment variable must be set' if ENV['SERPAPI_KEY'].nil?

require 'pp'
require 'serpapi'

default_params = {
  engine: 'google',
  api_key: ENV['SERPAPI_KEY']
}
client = SerpApi::Client.new(default_params)
params = {
  q: 'coffee'
}
results = client.search(params)
unless results[:organic_results]
  puts 'organic results found'
  exit 1
end
pp results[:organic_results]
puts 'done'
exit 0
