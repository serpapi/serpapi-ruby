require 'spec_helper'

describe 'example: google_maps_photos search' do
  it 'prints photos' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_maps_photos', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      data_id: '0x89c25998e556791b:0xbdcd67f46e37b16d'
    })
    expect(results[:photos]).not_to be_nil, "No photos found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:photos]
    # doc: http://serpapi.com/google-maps-photos-api
  end
end
