# basic application using serpapi
#

require 'serpapi'

raise 'API_KEY environment variable must be set' if ENV['API_KEY'].nil?

default_parameter = {
  engine: 'google_autocomplete',
  client: 'safari',
  hl: 'en',
  gl: 'us',
  api_key: ENV['API_KEY']
}

client = SerpApi::Client.new(default_parameter)
parameter = {
  q: 'coffee'
}
results = client.search(parameter)
pp results[:suggestions]
puts 'demo passed'
exit 0
