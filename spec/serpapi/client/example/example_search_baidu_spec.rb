require 'spec_helper'

describe 'example: baidu search' do
  it 'prints organic_results' do
    # Confirm that the environment variable for API_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['API_KEY']
    skip('API_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'baidu', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'coffee'
    })
    expect(results[:organic_results]).not_to be_nil, "No organic results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:organic_results]
    # doc: https://serpapi.com/baidu
  end
end
