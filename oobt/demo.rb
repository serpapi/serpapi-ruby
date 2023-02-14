# basic application implementing the serpapi client.
# for Out Of Box Testing

require 'serpapi'

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
pp results[:suggestions]
puts 'demo passed'
exit 0
