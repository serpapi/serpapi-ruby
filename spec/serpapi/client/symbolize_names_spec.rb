require 'spec_helper'
require 'stringio'

describe 'JSON parser option precedence' do
  let(:transport) { double('HTTP client') }
  let(:response) do
    double(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: '{"search_metadata":{"id":"offline"}}',
      flush: nil
    )
  end

  before do
    allow(HTTP).to receive(:timeout).and_return(transport)
    allow(transport).to receive(:get).and_return(response)
    allow(transport).to receive(:post).and_return(response)
  end

  [nil, true, false].each do |constructor_option|
    [nil, true, false].each do |call_option|
      it "decodes JSON with constructor #{constructor_option.inspect} and call #{call_option.inspect}" do
        defaults = { persistent: false }
        defaults[:symbolize_names] = constructor_option unless constructor_option.nil?
        params = { q: 'coffee' }
        params[:symbolize_names] = call_option unless call_option.nil?
        client = SerpApi::Client.new(defaults)
        symbolize = call_option.nil? ? constructor_option != false : call_option
        key = symbolize ? :search_metadata : 'search_metadata'
        nested_key = symbolize ? :id : 'id'

        expect(client.search(params)).to eq(key => { nested_key => 'offline' })
        expect(transport).to have_received(:get) do |_url, options|
          expect(options.fetch(:params)).not_to have_key(:symbolize_names)
        end
      end
    end
  end

  it 'uses constructor defaults for archived searches' do
    client = SerpApi::Client.new(persistent: false, symbolize_names: false)

    expect(client.search_archive('offline')).to have_key('search_metadata')
  end

  it 'uses constructor defaults and flushes persistent responses' do
    allow(transport).to receive(:persistent).and_return(transport)
    client = SerpApi::Client.new(symbolize_names: false)

    expect(client.search(q: 'coffee')).to have_key('search_metadata')
    expect(response).to have_received(:flush)
  end

  it 'uses constructor defaults for account responses' do
    client = SerpApi::Client.new(persistent: false, symbolize_names: false)

    expect(client.account).to have_key('search_metadata')
  end

  it 'uses constructor defaults for image uploads without sending parser options' do
    client = SerpApi::Client.new(persistent: false, symbolize_names: false)

    expect(client.upload_image(StringIO.new('image'))).to have_key('search_metadata')
    expect(transport).to have_received(:post) do |_url, options|
      expect(options.fetch(:form)).not_to have_key(:symbolize_names)
    end
  end

  it 'allows an image upload to override the constructor option' do
    client = SerpApi::Client.new(persistent: false, symbolize_names: false)

    expect(client.upload_image(StringIO.new('image'), symbolize_names: true)).to have_key(:search_metadata)
  end

  { html: 'text/html', md: 'text/markdown' }.each do |format, content_type|
    it "keeps #{format} responses as text" do
      allow(response).to receive(:headers).and_return('Content-Type' => content_type)
      allow(response).to receive(:body).and_return('raw text')
      client = SerpApi::Client.new(persistent: false, symbolize_names: false)

      expect(client.public_send(format, q: 'coffee')).to eq('raw text')
    end
  end
end
