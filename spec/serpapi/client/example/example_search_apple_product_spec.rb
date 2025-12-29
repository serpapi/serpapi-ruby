require 'spec_helper'

describe 'example: apple_product search' do
  it 'prints organic_results' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'apple_product', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      product_id: '534220544',
      type: 'app',
      country: 'us'
    })
    expect(results[:organic_results]).not_to be_nil, "No organic results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:organic_results]
    # doc: http://serpapi.com/apple-product-api
  end
end
