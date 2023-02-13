describe 'search google maps' do
  it 'prints local_results' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_maps')
    results = client.search({
      "q": "pizza",
      "ll": "@40.7455096,-74.0083012,15.1z",
      "type": "search"
    })
    expect(results[:local_results]).not_to be_nil
    # pp results[:local_results]
    # ENV['API_KEY'] captures the secret user API available from http://serpapi.com
  end
end
