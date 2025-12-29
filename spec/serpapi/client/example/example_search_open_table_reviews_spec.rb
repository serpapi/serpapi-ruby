require 'spec_helper'

describe 'example: open_table_reviews search' do
  it 'prints reviews[0]' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'open_table_reviews', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      query_key: 'place_id',
      place_id: 'central-park-boathouse-new-york-2'
    })
    expect(results[:reviews[0]]).not_to be_nil, "No reviews[0] found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:reviews[0]]
    # doc: http://serpapi.com/open-table-reviews-api
  end
end
