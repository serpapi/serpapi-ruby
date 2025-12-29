require 'spec_helper'

describe 'example: home_depot_product_reviews search' do
  it 'prints reviews' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'home_depot_product_reviews', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      product_id: '302752040',
      sort_by: 'photoreview'
    })
    expect(results[:reviews]).not_to be_nil, "No reviews found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:reviews]
    # doc: http://serpapi.com/home-depot-product-reviews-api
  end
end
