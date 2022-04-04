describe 'search walmart' do
  it 'prints organic results' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'walmart')
    results = client.search(query: 'coffee')
    expect(results[:organic_results]).not_to be_nil
    # pp results[:organic_results]
    # ENV['API_KEY'] captures the secret user API available from http://serpapi.com
  end
end
