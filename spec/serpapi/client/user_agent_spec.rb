require 'spec_helper'

describe 'SerpApi client usage reporting' do
  describe '.user_agent' do
    {
      ['ruby', '3.4.1', 'arm64-darwin-23'] => 'serpapi-ruby/1.0.3 ruby/3.4.1 (darwin; arm64)',
      ['ruby', '3.3.6', 'x86_64-linux'] => 'serpapi-ruby/1.0.3 ruby/3.3.6 (linux; x86_64)',
      ['ruby', '3.4.1', 'aarch64-linux-musl'] => 'serpapi-ruby/1.0.3 ruby/3.4.1 (linux; aarch64)',
      ['ruby', '3.4.1', 'x64-mingw-ucrt'] => 'serpapi-ruby/1.0.3 ruby/3.4.1 (mingw; x64)',
      ['jruby', '9.4.9.0', 'universal-java-21'] => 'serpapi-ruby/1.0.3 jruby/9.4.9.0 (java; universal)'
    }.each do |(engine, engine_version, platform), user_agent|
      it "is #{user_agent} for #{engine} #{engine_version} on #{platform}" do
        stub_const('SerpApi::VERSION', '1.0.3')
        stub_const('RUBY_ENGINE', engine)
        stub_const('RUBY_ENGINE_VERSION', engine_version)
        allow(Gem::Platform).to receive(:local).and_return(Gem::Platform.new(platform))

        expect(SerpApi::Client.user_agent).to eq(user_agent)
      end
    end
  end

  describe 'requests' do
    let(:response) do
      double(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' }, flush: nil)
    end

    [true, false].each do |persistent|
      it "send the User-Agent header instead of a source parameter when persistent is #{persistent}" do
        client = SerpApi::Client.new(api_key: 'dummy_secret_key', persistent: persistent)
        sent = nil
        allow_any_instance_of(HTTP::Client).to receive(:perform) do |_http, request, _options|
          sent = request
          response
        end

        client.search(q: 'Coffee')

        expect(sent.headers['User-Agent']).to eq(SerpApi::Client.user_agent)
        expect(URI.decode_www_form(sent.uri.query).to_h).to eq('api_key' => 'dummy_secret_key', 'q' => 'Coffee')
      end
    end
  end
end
