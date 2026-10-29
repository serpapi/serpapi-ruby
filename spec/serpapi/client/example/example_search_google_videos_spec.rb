require 'spec_helper'

describe 'example: google_videos search' do
  it 'prints video_results' do
    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_videos', api_key: api_key)
    # run a search using serpapi service
    results = client.search(
      q: 'coffee'
    )
    expect(results[:video_results]).not_to be_nil, "No video results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:video_results]
    # doc: https://serpapi.com/google-videos-api
  end
end
