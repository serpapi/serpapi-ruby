require 'spec_helper'

describe 'example: google_reverse_image search' do
  it 'prints image_results' do
    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_reverse_image', api_key: api_key)
    # run a search using serpapi service
    results = client.search(
      image_url: 'https://upload.wikimedia.org/wikipedia/commons/6/63/Wikipedia-logo.png'
    )
    expect(results[:image_results]).not_to be_nil, "No image results found! keys available: #{results.keys}"
    expect(results[:image_results]).not_to be_empty, 'No image results returned!'

    # print the output of the response in formatted JSON
    # pp results[:image_results]
    # doc: https://serpapi.com/google-reverse-image
  end
end
