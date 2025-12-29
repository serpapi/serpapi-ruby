require 'spec_helper'

describe 'example: google_shopping search' do
  it 'prints ai_overview' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_shopping', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'Iphone',
      location: 'Austin, Texas, United States',
      hl: 'en',
      gl: 'us',
      tbs: 'local_avail:1',
      device: 'mobile'
    })
    expect(results[:ai_overview]).not_to be_nil, "No ai overview found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:ai_overview]
    # doc: http://serpapi.com/google-shopping-api
  end
end
