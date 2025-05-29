# The code snippet you provided demonstrates a simple implementation of the SerpApi client using the Ruby Serpapi gem.
# It  performs a Google Autocomplete search for the query "coffee" and prints the suggestions returned.
#
# **Key Points:**
#
# * **API Key:** The code requires an API key to be set in the `API_KEY` environment variable.
# * **Serpapi Client:** A SerpApi client is created with default parameters, including the engine, client, language, 
# country, API key, persistence settings, and timeout.
# * **Search Parameters:** A search request is made with the query "coffee".
# * **Suggestions Retrieval:** The `suggestions` key in the response is checked for availability and non-emptiness.
# * **Output:** The suggestions are printed using the `pp` gem.
#
# **Purpose:**
#
# The code is designed to demonstrate how to use the SerpApi client to retrieve autocomplete suggestions from Google. It 
# verifies that suggestions are returned and outputs them for demonstration purposes.
#
# **Usage:**
#
# To run the code, you need to set the `API_KEY` environment variable to your actual SerpApi API key. 
# Obtain your free key from: serpapi.com
#
# **Output:**
#
# The script will output the autocomplete suggestions for the query "coffee" in a formatted manner.
#
# **Additional Notes:**
#
# * The `persistent: false` parameter ensures that each search request is treated as a new session. this is no the best pratice.
# * The `timeout: 2` parameter sets a timeout of 2 seconds for each request.
# * The code uses the `pp` gem for pretty-printing the suggestions.
# * The `exit 1` and `exit 0` statements are used to indicate success or failure, respectively.

require 'serpapi'
require 'pp'

raise 'API_KEY environment variable must be set' if ENV['API_KEY'].nil?

default_params = {
  engine: 'google_autocomplete',
  client: 'safari',
  hl: 'en',
  gl: 'us',
  api_key: ENV['API_KEY'],
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
