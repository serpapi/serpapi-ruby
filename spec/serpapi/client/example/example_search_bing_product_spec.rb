require 'spec_helper'

describe 'example: bing_product search' do
  it 'prints product_results' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'bing_product', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      product_token: 'pc13NHicdY3BbsIwEETVjyES8oUaEXrJAWgJqBQiwg-YeEOsWF53vRblV_s1jRIOPcBlR_tmRvP7Mv7O9qYFsbSqasWnsTY0yEKKHShugETpQLVAIamN5U6zUIFTZHA0VSMpX-fdEZfTzcMdyB5s9fDKVM5nMp1M32bp3dio0AzmpCe5xbOyh7oG2urwuLaI1Qodww_n0eh_7Zww-g_Hhm_PJvfoSo8uIIHuV4bYiSJ0knhCHSv26gIZdyxZH45fWbkpivciORNew8D_AJZIW7o'
    })
    expect(results[:product_results]).not_to be_nil, "No product results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:product_results]
    # doc: http://serpapi.com/bing-product-api
  end
end
