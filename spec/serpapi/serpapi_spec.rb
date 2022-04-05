require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe 'basic google search using SerpApi.com' do
  before(:all) do
    @search = SerpApi::Client.new(engine: 'google', api_key: ENV['API_KEY'])
  end

  it 'search for coffee in Austin, TX and receive json results' do
    data = @search.search(q: 'Coffee', location: 'Austin, TX')
    expect(data.size).to be > 5
    expect(data.class).to be Hash
    expect(data.keys.size).to be > 5
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
      raise("wrong exception: #{e}")
    end
  end

  it 'get parameter' do
    expect(@search.parameter[:api_key]).to eq(ENV['API_KEY'])
    expect(@search.api_key).to eq(ENV['API_KEY'])
    expect(@search.parameter[:engine]).to eq('google')
  end

  it 'start bad decoder' do
    begin
      @search.send(:start, '/search', :bad, {q: 'hello'})
    rescue SerpApi::SerpApiException => e
      expect(e.message).to include('not supported decoder')
    rescue => e
      raise("wrong exception: #{e}")
    end
  end

  it 'fail: get url' do
    allow(JSON).to receive(:parse) { {} }
    begin
      @search.search({})
    rescue SerpApi::SerpApiException => e
      expect(e.message).to include('fail: get url')
    rescue => e
      raise("wrong exception: #{e}")
    end
  end
end
