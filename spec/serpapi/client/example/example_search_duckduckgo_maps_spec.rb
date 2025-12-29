require 'spec_helper'

describe 'example: duckduckgo_maps search' do
  it 'prints local_results' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'duckduckgo_maps', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'Coffee',
      bbox: '30.341552964181687,-97.87405344947078,30.16321730812698,-97.50702877159034',
      strict_bbox: '0'
    })
    expect(results[:local_results]).not_to be_nil, "No local results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:local_results]
    # doc: http://serpapi.com/duckduckgo-maps-api
  end
end
