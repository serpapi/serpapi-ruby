require 'spec_helper'

describe 'example: google_trends_trending_now search' do
  it 'prints trending_searches' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_trends_trending_now', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      query_key: 'geo',
      geo: 'US',
      frequency: 'daily',
      date: '20230718',
      cat: 'all'
    })
    expect(results[:trending_searches]).not_to be_nil, "No trending searches found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:trending_searches]
    # doc: http://serpapi.com/google-trends-trending-now-api
  end
end
