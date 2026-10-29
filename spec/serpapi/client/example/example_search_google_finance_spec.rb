require 'spec_helper'

describe 'example: google_finance search' do
  it 'prints a stock summary' do
    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_finance', api_key: api_key)
    # run a search using serpapi service
    results = client.search(
      q: 'GOOG:NASDAQ'
    )
    expect(results[:summary]).not_to be_nil, "No stock summary found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:summary]
    # doc: https://serpapi.com/google-finance-api
  end
end
