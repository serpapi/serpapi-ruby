require 'spec_helper'

describe 'example: google_trends search' do
  it 'prints interest_over_time' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_trends', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'coffee,milk,bread,pasta,steak',
      data_type: 'TIMESERIES'
    })
    expect(results[:interest_over_time]).not_to be_nil, "No interest over time found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:interest_over_time]
    # doc: https://serpapi.com/google_trends
  end
end
