require 'spec_helper'

describe 'example: google_finance_markets search' do
  it 'prints market_trends' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_finance_markets', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      trend: 'indexes'
    })
    expect(results[:market_trends]).not_to be_nil, "No market trends found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:market_trends]
    # doc: http://serpapi.com/google-finance-markets-api
  end
end
