require 'spec_helper'

describe 'example: youtube search' do
  it 'prints video_results' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'youtube')
    results = client.search({
      'search_query': 'coffee'
    })
    expect(results[:video_results]).not_to be_nil
    # pp results[:video_results]
    # ENV['API_KEY'] captures the secret user API available from http://serpapi.com
  end
end
