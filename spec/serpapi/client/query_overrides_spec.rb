require 'spec_helper'
require 'stringio'
require 'uri'

describe 'query parameter overrides' do
  let(:transport) { HTTP::Client.new }
  let(:response) do
    double(status: 200, headers: { 'Content-Type' => 'application/json' }, body: '{}')
  end
  let(:requests) { [] }

  before do
    allow(HTTP).to receive(:timeout).and_return(transport)
    allow(transport).to receive(:perform) do |request, _options|
      requests << request
      response
    end
  end

  def query_values(name)
    URI.decode_www_form(requests.last.uri.query).select { |key, _| key == name }.map(&:last)
  end

  %w[engine api_key custom_backend_option].each do |name|
    [[name, name.to_sym], [name.to_sym, name]].each do |default_key, call_key|
      it "replaces #{default_key.inspect} with #{call_key.inspect} in the encoded request" do
        client = SerpApi::Client.new(default_key => 'default-value', persistent: false)
        params = { call_key => 'override-value' }.freeze

        client.search(params)

        expect(query_values(name)).to eq(['override-value'])
        expect(client.params[default_key]).to eq('default-value')
        expect(params).to eq(call_key => 'override-value')
      end
    end
  end

  [['output', :output], [:output, 'output']].each do |default_key, call_key|
    it "keeps output overrides working from #{default_key.inspect} to #{call_key.inspect}" do
      client = SerpApi::Client.new(default_key => 'html', persistent: false)

      client.search(call_key => 'md')

      expect(query_values('output')).to eq(['md'])
    end
  end

  it 'removes a default when its differently keyed override is nil' do
    client = SerpApi::Client.new('location' => 'Austin', persistent: false)

    client.search(location: nil)

    expect(query_values('location')).to eq([])
  end

  it 'retains defaults with no per-call override' do
    client = SerpApi::Client.new('engine' => 'google', persistent: false)

    client.search(q: 'coffee')

    expect(query_values('engine')).to eq(['google'])
    expect(query_values('q')).to eq(['coffee'])
  end

  [:engine, 'engine'].each do |key|
    it "keeps Extract engine forcing with #{key.inspect} defaults" do
      client = SerpApi::Client.new(key => 'google', persistent: false)

      client.extract(url: 'https://example.com/', 'engine' => 'bing')

      expect(query_values('engine')).to eq(['extract'])
    end
  end

  [:html, :md].each do |format|
    it "keeps #{format} output forcing with conflicting defaults and call keys" do
      client = SerpApi::Client.new('output' => 'json', persistent: false)

      client.public_send(format, output: 'json', 'output' => 'json')

      expect(query_values('output')).to eq([format.to_s])
    end
  end

  it 'preserves symbol-output precedence within a single call' do
    client = SerpApi::Client.new(persistent: false)

    client.search('output' => 'html', output: 'md')

    expect(query_values('output')).to eq(['md'])
  end

  it 'overrides a string-keyed API key in a multipart image upload' do
    client = SerpApi::Client.new('api_key' => 'default-value', persistent: false)
    image = StringIO.new('image-data')

    client.upload_image(image, api_key: 'override-value')

    body = +''
    requests.last.body.each { |chunk| body << chunk }
    expect(body.scan('name="api_key"').size).to eq(1)
    expect(body).to include('override-value', 'image-data')
    expect(body).not_to include('default-value')
    expect(image).not_to be_closed
  end

  it 'preserves array-valued backend parameters' do
    client = SerpApi::Client.new('include_tags' => ['title'], persistent: false)

    client.extract(url: 'https://example.com/', include_tags: ['main', 'article'])

    expect(query_values('include_tags')).to eq(['main', 'article'])
  end
end
