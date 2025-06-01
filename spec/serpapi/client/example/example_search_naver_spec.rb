require 'spec_helper'

describe 'example: naver search' do
  it 'prints ads_results' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'naver', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      query: 'coffee'
    })
    expect(results[:ads_results]).not_to be_nil, "No ads results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:ads_results]
    # doc: https://serpapi.com/naver-search-api
  end
end
