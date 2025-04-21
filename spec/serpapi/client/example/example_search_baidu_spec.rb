require 'spec_helper'

describe 'example: baidu search' do
  it 'prints organic_results' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'baidu')
    results = client.search({
      'q': 'coffee'
    })
    expect(results[:organic_results]).not_to be_nil
    # pp results[:organic_results]
    # ENV['API_KEY'] captures the secret user API available from http://serpapi.com
  end
end
