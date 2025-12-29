require 'spec_helper'

describe 'example: google_play_product search' do
  it 'prints product_info' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_play_product', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      store: 'apps',
      product_id: 'com.google.android.youtube',
      all_reviews: 'true',
      platform: 'phone',
      sort_by: '1',
      num: '40'
    })
    expect(results[:product_info]).not_to be_nil, "No product info found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:product_info]
    # doc: http://serpapi.com/google-play-product-api
  end
end
