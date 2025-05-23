require 'spec_helper'

describe 'example: google_product search' do
  it 'prints product_results' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_product')
    results = client.search({
      'q': 'coffee',
      'product_id': '4172129135583325756'
    })
    expect(results[:product_results]).not_to be_nil
    # pp results[:product_results]
    # ENV['API_KEY'] captures the secret user API available from http://serpapi.com
  end
end
