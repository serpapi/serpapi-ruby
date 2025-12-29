require 'spec_helper'

describe 'example: yahoo_videos search' do
  it 'prints videos_results' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'yahoo_videos', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      text: 'coffee'
    })
    expect(results[:videos_results]).not_to be_nil, "No videos results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:videos_results]
    # doc: http://serpapi.com/yahoo-videos-api
  end
end
