require 'date'
require 'spec_helper'

describe 'example: google_hotels search' do
  it 'prints properties' do
    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_hotels', api_key: api_key)
    check_in_date = Date.today + 30
    # run a search using serpapi service
    results = client.search(
      q: 'Bali Resorts',
      check_in_date: check_in_date.iso8601,
      check_out_date: (check_in_date + 1).iso8601,
      adults: '2',
      currency: 'USD',
      gl: 'us',
      hl: 'en'
    )
    expect(results[:properties]).not_to be_nil, "No properties found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:properties]
    # doc: https://serpapi.com/google-hotels-api
  end
end
