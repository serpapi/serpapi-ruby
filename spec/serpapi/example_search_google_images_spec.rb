describe 'search google images' do
  it 'prints first 5 links to coffee images' do
    client = SerpApi::Client.new(tbm: 'isch', api_key: ENV['API_KEY'], engine: 'google')
    image_results_list = client.search(q: 'coffee')[:images_results]
    expect(image_results_list.size).to be >= 3
    image_results_list[0..2].each do |image_result|
      puts image_result[:original]
    end
  end
end
