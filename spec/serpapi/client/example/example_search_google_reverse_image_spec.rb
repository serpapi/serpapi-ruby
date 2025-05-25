require 'spec_helper'

describe 'example: google_reverse_image search' do
  it 'prints image_sizes' do
    # Confirm that the environment variable for API_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['API_KEY']
    skip('API_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_reverse_image', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      image_url: 'https://i.imgur.com/5bGzZi7.jpg'
    })
    expect(results[:image_sizes]).not_to be_nil, "No image sizes found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:image_sizes]
    # doc: https://serpapi.com/google_reverse_image
  end
end
