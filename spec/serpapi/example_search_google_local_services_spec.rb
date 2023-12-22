describe 'example: google_local_services search' do
  it 'prints local_ads' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_local_services')
    results = client.search({
      'q': 'electrician',
      'data_cid': '14414772292044717666'
    })
    expect(results[:local_ads]).not_to be_nil
    # pp results[:local_ads]
    # ENV['API_KEY'] captures the secret user API available from http://serpapi.com
  end
end
