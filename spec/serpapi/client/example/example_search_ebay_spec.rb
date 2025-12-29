require 'spec_helper'

describe 'example: ebay search' do
  it 'prints inline_results' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'ebay', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      _nkw: 'Nintendo Switch'
    })
    expect(results[:inline_results]).not_to be_nil, "No inline results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:inline_results]
    # doc: http://serpapi.com/ebay-search-api
  end
end
