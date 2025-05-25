require 'spec_helper'

describe 'example: google_local_services search' do
  it 'prints local_ads' do
    # Confirm that the environment variable for API_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['API_KEY']
    skip('API_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_local_services', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'electrician',
      data_cid: '6745062158417646970'
    })
    expect(results[:local_ads]).not_to be_nil, "No local ads found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:local_ads]
    # doc: https://serpapi.com/google_local_services
  end
end
