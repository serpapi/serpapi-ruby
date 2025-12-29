require 'spec_helper'

describe 'example: yelp_place search' do
  it 'prints place_results' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'yelp_place', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      place_id: 'maman-new-york-22',
      full_menu: 'true',
      query_key: 'place_id'
    })
    expect(results[:place_results]).not_to be_nil, "No place results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:place_results]
    # doc: http://serpapi.com/yelp-place-api
  end
end
