require 'spec_helper'

describe 'example: google_lens search' do
  it 'prints visual_matches' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_lens', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      url: 'https://i.imgur.com/HBrB8p0.png'
    })
    expect(results[:visual_matches]).not_to be_nil, "No visual matches found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:visual_matches]
    # doc: https://serpapi.com/google_lens
  end
end
