require 'spec_helper'

describe 'example: google_trends_news search' do
  it 'prints trending_searches' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_trends_news', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      page_token: 'GOpbs3ica1xTlFpYmlpcEp-SWJI4bfK5BzeuRi5KzVsUGjz53MObP3Rg7LvN0xXg4jUfT8HZd3nPwthgvXk5QDYAHy0v_g'
    })
    expect(results[:trending_searches]).not_to be_nil, "No trending searches found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:trending_searches]
    # doc: http://serpapi.com/google-trends-news-api
  end
end
