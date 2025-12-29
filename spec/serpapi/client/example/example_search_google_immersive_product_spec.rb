require 'spec_helper'

describe 'example: google_immersive_product search' do
  it 'prints product_results.stores' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_immersive_product', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      query_key: 'page_token',
      page_token: 'eyJlaSI6IjE0NXFaN0NlS3U3bjVOb1BtcmpTOFFvIiwicHJvZHVjdGlkIjoiIiwiY2F0YWxvZ2lkIjoiMTY5MTQ4Nzc2MjUyODA5Nzc4NjUiLCJoZWFkbGluZU9mZmVyRG9jaWQiOiIzMjM4MjI0ODQ0NjI0OTEyMTY5IiwiaW1hZ2VEb2NpZCI6IjQ3Njc0OTkxNTkwNjMyNzkxNCIsInJkcyI6IlBDXzMyNDU0NzY0MDA4MzM1NTE5NDh8UFJPRF9QQ18zMjQ1NDc2NDAwODMzNTUxOTQ4IiwicXVlcnkiOiIrQ29mZmVlIiwiZ3BjaWQiOiIzMjQ1NDc2NDAwODMzNTUxOTQ4IiwibWlkIjoiNTc2NDYyNjEyMjgwMTMwNDgxIiwicHZ0IjoiaGciLCJ1dWxlIjpudWxsfQ==',
      more_stores: 'true'
    })
    expect(results[:product_results.stores]).not_to be_nil, "No product results.stores found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:product_results.stores]
    # doc: http://serpapi.com/google-immersive-product-api
  end
end
