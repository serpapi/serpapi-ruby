require 'spec_helper'

# These specs only build clients, so they make no HTTP request to serpapi.com.
describe 'SerpApi::Client constructor' do
  it 'does not modify the params hash passed by the caller' do
    config = { engine: 'google', api_key: 'test_key', timeout: 10, persistent: false }
    original = config.dup

    SerpApi::Client.new(config)

    expect(config).to eq(original)
  end

  it 'gives the same settings to every client built from a reused config hash' do
    config = { engine: 'google', api_key: 'test_key', timeout: 10, persistent: false }

    first = SerpApi::Client.new(config)
    second = SerpApi::Client.new(config)

    expect(second.timeout).to eq(first.timeout)
    expect(second.timeout).to eq(10)
    expect(second.persistent).to be false
    expect(second.socket).to be_nil
  end

  it 'accepts a frozen params hash' do
    config = { engine: 'google', api_key: 'test_key', timeout: 10, persistent: false }.freeze

    client = SerpApi::Client.new(config)

    expect(client.timeout).to eq(10)
    expect(client.persistent).to be false
    expect(client.engine).to eq('google')
  end

  it 'keeps timeout and persistent out of the query parameters' do
    client = SerpApi::Client.new(engine: 'google', api_key: 'test_key', timeout: 10, persistent: false)

    expect(client.params).not_to have_key(:timeout)
    expect(client.params).not_to have_key(:persistent)
  end

  it 'defaults to a 120 second timeout and persistent mode' do
    client = SerpApi::Client.new(engine: 'google', api_key: 'test_key')

    expect(client.timeout).to eq(120)
    expect(client.persistent).to be true
    expect(client.socket).not_to be_nil
    client.close
  end
end
