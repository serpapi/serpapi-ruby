# this demo demonstrates a simple implementation of serpapi client.
#
require 'serpapi'
require 'pp'

raise 'API_KEY environment variable must be set' if ENV['API_KEY'].nil?

default_params = {
  engine: 'google_autocomplete',
  client: 'safari',
  hl: 'en',
  gl: 'us',
  api_key: ENV['API_KEY']
}
client = SerpApi::Client.new(default_params)
params = {
  q: 'coffee'
}
results = client.search(params)
puts 'print suggestions'
if !results[:suggestions] || results[:suggestions].empty?
  puts 'demo failed because no suggestions were found'
  exit 1
end
pp results[:suggestions]
puts 'demo passed'
exit 0
