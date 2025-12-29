require 'spec_helper'

describe 'example: google_reverse_image search' do
  it 'prints inline_images' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_reverse_image', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      image_url: 'https://i.imgur.com/5bGzZi7.jpg'
    })
    expect(results[:inline_images]).not_to be_nil, "No inline images found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:inline_images]
    # doc: http://serpapi.com/google-reverse-image
  end
end
