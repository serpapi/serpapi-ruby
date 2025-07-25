require 'spec_helper'

describe 'example: google_images search' do
  it 'prints images_results' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_images', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      tbm: 'isch',
      q: 'coffee'
    })
    expect(results[:images_results]).not_to be_nil, "No images results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:images_results]
    # doc: https://serpapi.com/images-results
  end
end
