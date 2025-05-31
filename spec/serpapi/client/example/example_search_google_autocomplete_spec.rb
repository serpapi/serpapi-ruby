require 'spec_helper'

describe 'example: google_autocomplete search' do
  it 'prints suggestions' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_autocomplete', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'coffee'
    })
    expect(results[:suggestions]).not_to be_nil, "No suggestions found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:suggestions]
    # doc: https://serpapi.com/google_autocomplete
  end
end
