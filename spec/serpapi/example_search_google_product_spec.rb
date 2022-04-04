describe 'search google product' do
  it 'prints product results' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_product')
    results = client.search(product_id: '4172129135583325756')
    expect(results[:product_results]).not_to be_nil
    # pp results[:product_results]
    # ENV['API_KEY'] captures the secret user API available from http://serpapi.com
  end
end
