require 'spec_helper'

describe 'example: google_maps_reviews search' do
  it 'prints reviews' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_maps_reviews', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      data_id: '0x89c259af336b3341:0xa4969e07ce3108de',
      hl: 'fr'
    })
    expect(results[:reviews]).not_to be_nil, "No reviews found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:reviews]
    # doc: http://serpapi.com/google-maps-reviews-api
  end
end
