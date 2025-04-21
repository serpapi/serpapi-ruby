require 'spec_helper'

describe 'client full coverage' do
  before(:all) do
    pp Module.constants.select { |c| c.to_s =~ /SerpApi/ }
    @client = SerpApi::Client.new(engine: 'google', api_key: ENV['API_KEY'], timeout: 30)
  end

  it 'search for coffee in Austin, TX and receive json results' do
    data = @client.search(q: 'Coffee', location: 'Austin, TX')
    expect(data.size).to be > 5
    expect(data.class).to be Hash
    expect(data.keys.size).to be > 5
  end

  it 'search fir coffee in Austin, TX and receive raw HTML' do
    data = @client.html(q: 'Coffee', location: 'Austin, TX')
    expect(data).to match(/coffee/i)
  end

  it 'missing query' do
    begin
      @client.search({})
    rescue SerpApi::Errors::SerpApiException => e
      expect(e.message).to include('Missing query')
    rescue => e
      raise("wrong exception: #{e}")
    end
  end

  it 'get params' do
    expect(@client.params[:api_key]).to eq(ENV['API_KEY'])
  end

  it 'api_key' do
    expect(@client.api_key).to eq(ENV['API_KEY'])
  end

  it 'engine' do
    expect(@client.engine).to eq('google')
  end

  it 'timeout' do
    expect(@client.timeout).to eq(30)
  end

  it 'get bad decoder' do
    begin
      @client.send(:get, '/search', :bad, {q: 'hello'})
    rescue SerpApi::Errors::SerpApiException => e
      expect(e.message).to include('not supported decoder')
    rescue => e
      raise("wrong exception: #{e}")
    end
  end

  it 'fail: get url' do
    allow(JSON).to receive(:parse) { {} }
    begin
      @client.search({})
    rescue SerpApi::Errors::SerpApiException => e
      expect(e.message).to include('fail: get url')
    rescue => e
      raise("wrong exception: #{e}")
    end
  end
end
