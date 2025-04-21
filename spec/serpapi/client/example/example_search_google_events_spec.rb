require 'spec_helper'

describe 'example: google_events search' do
  it 'prints events_results' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_events')
    results = client.search({
      'q': 'coffee'
    })
    expect(results[:events_results]).not_to be_nil
    # pp results[:events_results]
    # ENV['API_KEY'] captures the secret user API available from http://serpapi.com
  end
end
