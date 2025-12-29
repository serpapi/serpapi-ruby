require 'spec_helper'

describe 'example: bing_copilot search' do
  it 'prints text_blocks' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'bing_copilot', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'new shopping things'
    })
    expect(results[:text_blocks]).not_to be_nil, "No text blocks found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:text_blocks]
    # doc: http://serpapi.com/bing-copilot-api
  end
end
