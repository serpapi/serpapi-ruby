require 'spec_helper'

describe 'example: google_maps search' do
  it 'prints local_results' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_maps', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'coffee',
      ll: '@40.7455096,-74.0083012,15.1z',
      type: 'search',
      data: '%214m5%213m4%211s0x89c259a61c75684f%3A0x79d31adb123348d2%218m2%213d40.7457399%214d-73.9882272'
    })
    expect(results[:local_results]).not_to be_nil, "No local results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:local_results]
    # doc: http://serpapi.com/google-maps-api
  end
end
