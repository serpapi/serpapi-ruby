require 'spec_helper'

describe 'example: yahoo_shopping search' do
  it 'prints shopping_results' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'yahoo_shopping', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      p: 'coffee',
      merchants: '3cf3c2e4-90aa-4398-a970-83eb69413f9b',
      min_price: '500',
      max_price: '2000',
      sort_by: 'discountPercentage'
    })
    expect(results[:shopping_results]).not_to be_nil, "No shopping results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:shopping_results]
    # doc: http://serpapi.com/yahoo-shopping-api
  end
end
