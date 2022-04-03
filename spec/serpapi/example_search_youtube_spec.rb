describe 'search youtube' do
  it 'prints first 5 links to coffee videos' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'])
    query = {
      engine: 'youtube',
      search_query: 'Coffee'
    }
    hash = client.search(query)
    expect(hash[:video_results].size).to be >= 3
    hash[:video_results][0..2].each do |video|
      puts video[:link]
    end
  end
end
