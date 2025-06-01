require 'spec_helper'

describe 'example: google_hotels search' do
  it 'prints properties' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_hotels', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'Bali Resorts',
      check_in_date: '2025-05-26',
      check_out_date: '2025-05-27',
      adults: '2',
      currency: 'USD',
      gl: 'us',
      hl: 'en'
    })
    expect(results[:properties]).not_to be_nil, "No properties found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:properties]
    # doc: https://serpapi.com/google-hotels-api
  end
end
