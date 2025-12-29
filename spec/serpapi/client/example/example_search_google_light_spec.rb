require 'spec_helper'

describe 'example: google_light search' do
  it 'prints answer_box' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_light', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'luke skywalker lightsaber color',
      hl: 'en',
      gl: 'us',
      location: 'Austin, Texas, United States',
      start: '50'
    })
    expect(results[:answer_box]).not_to be_nil, "No answer box found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:answer_box]
    # doc: http://serpapi.com/google-light-api
  end
end
