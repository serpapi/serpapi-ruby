describe 'search google play' do
  # TODO backend is temporary not working
  xit 'prints organic_results' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_play')
    results = client.search({
      "q": "kite",
      "store": "apps"
    })
    expect(results[:organic_results]).not_to be_nil
    # pp results[:organic_results]
    # ENV['API_KEY'] captures the secret user API available from http://serpapi.com
  end
end
