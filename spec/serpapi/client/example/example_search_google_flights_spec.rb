require 'spec_helper'

describe 'example: google_flights search' do
  it 'prints price_insights' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_flights', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      departure_id: 'PEK',
      arrival_id: 'AUS',
      currency: 'USD',
      hl: 'en',
      booking_token: 'WyJDalJJYjJkRGNubFBWekpGVkhkQlFUazJTa0ZDUnkwdExTMHRMUzB0TFhCbVltWnhOa0ZCUVVGQlIxWm5UWE5SUlY5RU4wRkJFZ2RDUVRNeU9DTXhHZ3NJMTVJQkVBSWFBMVZUUkRnY2NOZVNBUT09IixbWyJDREciLCIyMDIzLTEyLTA1IiwiTEhSIixudWxsLCJCQSIsIjMwMyJdXSxbWyJMSFIiLCIyMDIzLTEyLTI4IiwiQ0RHIixudWxsLCJCQSIsIjMyOCJdXV0='
    })
    expect(results[:price_insights]).not_to be_nil, "No price insights found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:price_insights]
    # doc: http://serpapi.com/google-flights-api
  end
end
