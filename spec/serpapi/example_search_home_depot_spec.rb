describe 'search home depot' do
  it 'prints products' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'home_depot')
    results = client.search({
      "q": "table"
    })
    expect(results[:products]).not_to be_nil
    # pp results[:products]
    # ENV['API_KEY'] captures the secret user API available from http://serpapi.com
  end
end
