require 'spec_helper'

describe 'example: google_autocomplete search' do
  it 'prints suggestions' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_autocomplete')
    results = client.search({
      'q': 'coffee'
    })
    expect(results[:suggestions]).not_to be_nil
    # pp results[:suggestions]
    # ENV['API_KEY'] captures the secret user API available from http://serpapi.com
  end
end
