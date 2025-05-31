require 'spec_helper'

describe 'set of client test to archieve full code coverage' do
  let(:client) do
    client = SerpApi::Client.new(engine: 'google', api_key: ENV['SERPAPI_KEY'], timeout: 30)
  end

  it 'search for coffee in Austin, TX, returns symbolized Hash' do
    results = client.search(q: 'Coffee', location: 'Austin, TX')

    expect(results.size).to be > 5
    expect(results.class).to be Hash
    expect(results.keys.size).to be > 5

    expect(results.keys).to include(:search_metadata), ':search_metadata should be present in the results'
  end

  it 'search for coffee in Austin, TX, returns non-symbolized Hash' do
    results = client.search(q: 'Coffee', location: 'Austin, TX', symbolize_names: false)

    expect(results.size).to be > 5
    expect(results.class).to be Hash
    expect(results.keys.size).to be > 5

    expect(results.keys).to include('search_metadata'), 'search_metadata should be present in the results'
  end

  it 'search for coffee in Austin, TX and receive raw HTML' do
    results = client.html(q: 'Coffee', location: 'Austin, TX')
    expect(results).to match(/coffee/i)
  end

  it 'missing query' do
    begin
      client.search({})
    rescue SerpApi::SerpApiError => e
      expect(e.message).to include('Missing query')
    rescue => e
      raise("wrong exception: #{e}")
    end
  end

  it 'get params' do
    expect(client.params[:api_key]).to eq(ENV['SERPAPI_KEY'])
  end

  it 'api_key' do
    expect(client.api_key).to eq(ENV['SERPAPI_KEY'])
  end

  it 'engine' do
    expect(client.engine).to eq('google')
  end

  it 'timeout' do
    expect(client.timeout).to eq(30)
  end

  it 'persistent' do
    expect(client.persistent).to be true
  end

  it 'get bad decoder' do
    begin
      client.send(:get, '/search', :bad, {q: 'hello'})
    rescue SerpApi::SerpApiError => e
      expect(e.message).to include('not supported decoder')
    rescue => e
      raise("wrong exception: #{e}")
    end
  end

  it 'get endpoint error' do
    expect { 
      client.send(:get, '/search', :json, {}) 
    }.to raise_error(SerpApi::SerpApiError).with_message(/HTTP request failed with error: Missing query `q` parameter./)
  end

  it 'get bad endpoint' do
    begin
      client.send(:get, '/invalid', :json, {})
    rescue SerpApi::SerpApiError => e
      expect(e.message).to include('JSON parse error')
    rescue => e
      raise("wrong exception: #{e}")
    end
  end

  it 'get bad html endpoint' do
    begin
      client.send(:get, '/invalid', :html, {})
    rescue SerpApi::SerpApiError => e
      expect(e.message).to include(/HTTP request failed with response status: 404 Not Found reponse/), "got #{e.message}"
    rescue => e
      raise("wrong exception: #{e}")
    end
  end
end

describe 'SerpApi client with persitency enable' do

  let(:client) do
    SerpApi::Client.new(engine: 'google', api_key: ENV['SERPAPI_KEY'], timeout: 10, persistent: true) 
  end

  it 'check socket is open when persistent mode is enabled' do    
    expect(client.socket).to_not be_nil
    expect(client.persistent).to be true
  end

  it 'makes a search request with valid parameters' do
    results = client.search(q: 'Coffee', location: 'Austin, TX')
    expect(results.size).to be > 5
    expect(results.class).to be Hash
    expect(results.keys.size).to be > 5
    expect(results[:search_metadata][:id]).not_to be_nil

    expect(client.close).to eq(:clean)
  end

  it 'handles API errors' do
    allow(client).to receive(:search).and_raise(SerpApi::SerpApiError)
    expect { client.search(q: 'Invalid Query') }.to raise_error(SerpApi::SerpApiError)
  end

end

describe 'SerpApi client with persitency disabled' do
  it 'check socket is closed when persistent mode is disabled' do
    client = SerpApi::Client.new(engine: 'google', api_key: ENV['SERPAPI_KEY'], timeout: 10, persistent: false)
    expect(client.persistent).to be false
    expect(client.socket).to be_nil
    expect(client.close).to be_nil

    client.search(q: 'Coffee', location: 'Austin, TX')
    expect(client.socket).to be_nil
    expect(client.close).to be_nil
  end
end