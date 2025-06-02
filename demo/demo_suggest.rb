# This script demonstrates how to use the SerpApi Ruby client to fetch Google Autocomplete suggestions.
# It requires the `serpapi` gem and an environment variable `SERPAPI_KEY` containing your SerpApi API key.
#
# The script initializes the SerpApi client with default parameters, performs a search query for "coffee",
# and prints the autocomplete suggestions if available. If no suggestions are found, the script exits with an error.
#
# Prerequisites:
# - Install the `serpapi` gem (`gem install serpapi`).
# - Set the `SERPAPI_KEY` environment variable with your SerpApi API key.
# you can obtain an API key by signing up at https://serpapi.com.
#
# Usage:
# Run the script in a terminal:
# ruby demo_suggest.rb
require 'serpapi'
require 'pp'

raise 'SERPAPI_KEY environment variable must be set' if ENV['SERPAPI_KEY'].nil?

default_params = {
  engine: 'google_autocomplete',
  client: 'safari',
  hl: 'en',
  gl: 'us',
  api_key: ENV.fetch('SERPAPI_KEY', nil),
  persistent: false,
  timeout: 2
}
client = SerpApi::Client.new(default_params)
params = {
  q: 'coffee'
}
results = client.search(params)
puts 'print suggestions'
if !results[:suggestions] || results[:suggestions].empty?
  puts 'no suggestions found'
  exit 1
end
pp results[:suggestions]
puts 'done'
exit 0
