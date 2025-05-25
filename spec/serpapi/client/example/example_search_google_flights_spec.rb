require 'spec_helper'

describe 'example: google_flights search' do
  it 'prints best_flights' do
    # Confirm that the environment variable for API_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['API_KEY']
    skip('API_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_flights', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      departure_id: 'PEK',
      arrival_id: 'AUS',
      outbound_date: '2025-05-26',
      return_date: '2025-06-01',
      currency: 'USD',
      hl: 'en'
    })
    expect(results[:best_flights]).not_to be_nil, "No best flights found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:best_flights]
    # doc: https://serpapi.com/google_flights
  end
end
