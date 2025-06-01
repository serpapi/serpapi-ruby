require 'spec_helper'

describe 'example: google_immersive_product search' do
  it 'prints immersive_product_results' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_immersive_product', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'coffee'
    })
    expect(results[:immersive_product_results]).not_to be_nil, "No immersive product results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:immersive_product_results]
    # doc: https://serpapi.com/google-immersive-product-api
  end
end
