require 'spec_helper'

describe 'example: google_maps_directions search' do
  it 'prints directions' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_maps_directions', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      start_addr: 'Austin-Bergstrom International Airport',
      end_addr: '5540 N Lamar Blvd, Austin, TX 78756, USA'
    })
    expect(results[:directions]).not_to be_nil, "No directions found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:directions]
    # doc: http://serpapi.com/google-maps-directions-api
  end
end
