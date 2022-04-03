require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe 'basic google search using SerpApi.com' do
  before(:all) do
    @search = SerpApi::Client.new(engine: 'google', api_key: ENV['API_KEY'])
  end

  it 'search for coffee in Austin, TX and receive json results' do
    json = @search.search(q: 'Coffee', location: 'Austin, TX')
    expect(json.size).to be > 7
    expect(json.class).to be Hash
    expect(json.keys.size).to be > 5
  end

  it 'search fir coffee in Austin, TX and receive raw HTML' do
    data = @search.html(q: 'Coffee', location: 'Austin, TX')
    expect(data).to match(/coffee/i)
  end

  it 'missing query' do
    begin
      @search.search({})
    rescue SerpApi::SerpApiException => e
      expect(e.message).to include('Missing query `q` parameter')
    rescue => e
      fail("wrong exception: #{e}")
    end
  end
end
