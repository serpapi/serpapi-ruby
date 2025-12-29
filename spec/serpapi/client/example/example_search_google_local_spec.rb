require 'spec_helper'

describe 'example: google_local search' do
  it 'prints local_results' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_local', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'Coffee',
      location: 'New York, New York, United States'
    })
    expect(results[:local_results]).not_to be_nil, "No local results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:local_results]
    # doc: http://serpapi.com/google-local-api
  end
end
