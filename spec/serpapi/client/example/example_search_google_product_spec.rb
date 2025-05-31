require 'spec_helper'

describe 'example: google_product search' do
  it 'prints product_results' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_product', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'coffee',
      product_id: '4887235756540435899'
    })
    expect(results[:product_results]).not_to be_nil, "No product results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:product_results]
    # doc: https://serpapi.com/google_product
  end
end
