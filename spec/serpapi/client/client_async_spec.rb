# Run search in parallel using Async 
#   and Gem async/http/faraday
#
# https://lostisland.github.io/faraday/#/advanced/parallel-requests
#

require 'spec_helper'
require 'async/http/faraday'

describe 'client adapter with async/http/faraday' do

  it 'test httpclient (requires faraday/httpclient)' do
    adapter = :async_http
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], timeout: 10, adapter: adapter)

    # run same query in parallel
    Async do
      Async do
        data = client.search(engine: 'google', q: 'Coffee', location: 'Austin, TX')
        expect(data.keys.size).to be > 5
        expect(data.dig(:search_metadata,:id)).not_to be_nil
      end
      Async do
        data = client.search(engine: 'youtube', search_query: 'Coffee', location: 'Austin, TX')
        expect(data.keys.size).to be > 5
        expect(data.dig(:search_metadata,:id)).not_to be_nil
      end
    end
  end
end
