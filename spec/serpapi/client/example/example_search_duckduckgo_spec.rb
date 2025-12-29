require 'spec_helper'

describe 'example: duckduckgo search' do
  it 'prints ads' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'duckduckgo', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'bitcoin'
    })
    expect(results[:ads]).not_to be_nil, "No ads found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:ads]
    # doc: http://serpapi.com/duckduckgo-search-api
  end
end
