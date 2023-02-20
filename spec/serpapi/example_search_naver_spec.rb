describe 'example: naver search' do
  it 'prints ads_results' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'naver')
    results = client.search({
      'query': 'coffee'
    })
    expect(results[:ads_results]).not_to be_nil
    # pp results[:ads_results]
    # ENV['API_KEY'] captures the secret user API available from http://serpapi.com
  end
end