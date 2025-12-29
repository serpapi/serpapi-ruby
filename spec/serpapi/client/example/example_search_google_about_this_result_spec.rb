require 'spec_helper'

describe 'example: google_about_this_result search' do
  it 'prints about_this_result' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_about_this_result', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'About https://www.starbucks.com/'
    })
    expect(results[:about_this_result]).not_to be_nil, "No about this result found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:about_this_result]
    # doc: http://serpapi.com/google-about-this-result-api
  end
end
