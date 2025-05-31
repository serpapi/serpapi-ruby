require 'spec_helper'

describe 'example: home_depot search' do
  it 'prints products' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'home_depot', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'table'
    })
    expect(results[:products]).not_to be_nil, "No products found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:products]
    # doc: https://serpapi.com/home_depot
  end
end
