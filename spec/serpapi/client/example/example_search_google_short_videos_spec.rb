require 'spec_helper'

describe 'example: google_short_videos search' do
  it 'prints short_video_results' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_short_videos', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'iPhone',
      hl: 'en',
      gl: 'us',
      device: 'mobile'
    })
    expect(results[:short_video_results]).not_to be_nil, "No short video results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:short_video_results]
    # doc: http://serpapi.com/google-short-videos-api
  end
end
