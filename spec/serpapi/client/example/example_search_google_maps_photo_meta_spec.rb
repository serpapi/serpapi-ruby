require 'spec_helper'

describe 'example: google_maps_photo_meta search' do
  it 'prints user' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_maps_photo_meta', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      data_id: 'AF1QipPFfVtTCFKV9n-uOBqTTOHuRemFBg0PWN7xdVxp'
    })
    expect(results[:user]).not_to be_nil, "No user found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:user]
    # doc: http://serpapi.com/google-maps-photo-meta-api
  end
end
