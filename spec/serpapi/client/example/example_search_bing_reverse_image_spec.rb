require 'spec_helper'

describe 'example: bing_reverse_image search' do
  it 'prints related_content' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'bing_reverse_image', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      query_key: 'image_url',
      image_url: 'https://i.imgur.com/HBrB8p0.png'
    })
    expect(results[:related_content]).not_to be_nil, "No related content found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:related_content]
    # doc: http://serpapi.com/bing-reverse-image-api
  end
end
