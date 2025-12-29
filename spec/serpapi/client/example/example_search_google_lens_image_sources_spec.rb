require 'spec_helper'

describe 'example: google_lens_image_sources search' do
  it 'prints image_sources' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_lens_image_sources', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      page_token: 'NGE1MjU3YmYtYjU2OC00OWRhLWE2MTAtNGMwMzUyZDI4MWQx'
    })
    expect(results[:image_sources]).not_to be_nil, "No image sources found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:image_sources]
    # doc: http://serpapi.com/google-lens-image-sources-api
  end
end
