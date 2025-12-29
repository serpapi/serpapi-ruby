require 'spec_helper'

describe 'example: google_maps_posts search' do
  it 'prints posts' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_maps_posts', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      data_id: '0x89c258e28c304997:0xfcafe4e7ce35ee8c'
    })
    expect(results[:posts]).not_to be_nil, "No posts found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:posts]
    # doc: http://serpapi.com/google-maps-posts-api
  end
end
