require 'spec_helper'

describe 'example: walmart_product search' do
  it 'prints product_result' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'walmart_product', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      product_id: '147423982'
    })
    expect(results[:product_result]).not_to be_nil, "No product result found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:product_result]
    # doc: http://serpapi.com/walmart-product-api
  end
end
