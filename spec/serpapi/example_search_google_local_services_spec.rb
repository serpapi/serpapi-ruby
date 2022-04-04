describe 'search google local services' do
  it 'prints local ads' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_local_services')
    results = client.search(q: 'Electrician', place_id: 'ChIJOwg_06VPwokRYv534QaPC8g')
    expect(results[:local_ads]).not_to be_nil
    # pp results[:local_ads]
    # ENV['API_KEY'] captures the secret user API available from http://serpapi.com
  end
end
