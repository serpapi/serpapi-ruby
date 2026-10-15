require 'spec_helper'

describe 'Extract API' do
  let(:client) { SerpApi::Client.new(api_key: 'dummy_secret_key', persistent: false) }

  # Returns the query parameters sent over HTTP, after merging client defaults.
  def sent_params
    http = double
    response = double(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
    sent = nil
    allow(HTTP).to receive(:timeout).and_return(http)
    allow(http).to receive(:get) do |_url, params:|
      sent = params
      response
    end
    yield
    sent
  end

  describe '#extract' do
    it 'forces the extract engine and passes the url' do
      expect(client).to receive(:search).with(hash_including(engine: 'extract', url: 'https://example.com/'))
      client.extract(url: 'https://example.com/')
    end

    it 'accepts extra parameters like mode, max_pages and max_depth' do
      expect(client).to receive(:search).with(
        hash_including(
          engine: 'extract',
          url: 'https://books.toscrape.com/',
          mode: 'crawl',
          max_pages: 3,
          max_depth: 1
        )
      )
      client.extract(url: 'https://books.toscrape.com/', mode: 'crawl', max_pages: 3, max_depth: 1)
    end

    it 'overrides a conflicting engine parameter' do
      expect(client).to receive(:search).with(hash_including(engine: 'extract'))
      client.extract(url: 'https://example.com/', engine: 'google')
    end

    it 'replaces a string-keyed engine parameter' do
      params = sent_params { client.extract('url' => 'https://example.com/', 'engine' => 'google') }
      expect(params.select { |key, _| key.to_s == 'engine' }).to eq(engine: 'extract')
    end

    it 'replaces a string-keyed engine from the client defaults' do
      client = SerpApi::Client.new('engine' => 'google', api_key: 'dummy_secret_key', persistent: false)
      params = sent_params { client.extract(url: 'https://example.com/') }
      expect(params.select { |key, _| key.to_s == 'engine' }).to eq(engine: 'extract')
    end

    it 'raises an error when url is missing' do
      expect { client.extract }.to raise_error(SerpApi::SerpApiError, /url parameter is required/)
      expect { client.extract(mode: 'map') }.to raise_error(SerpApi::SerpApiError, /url parameter is required/)
    end

    it 'raises an error when params is not a hash' do
      expect { client.extract('https://example.com/') }.to raise_error(SerpApi::SerpApiError, /params must be hash/)
    end
  end

  describe '#extract_link' do
    let(:link) do
      'https://serpapi.com/search.json?device=desktop&engine=extract&url=https%3A%2F%2Fiana.org%2Fdomains%2Fexample'
    end

    it 'parses the link query and re-issues the search through the client' do
      expect(client).to receive(:search).with(
        hash_including(
          engine: 'extract',
          device: 'desktop',
          url: 'https://iana.org/domains/example'
        )
      )
      client.extract_link(link)
    end

    it 'applies parameter overrides' do
      expect(client).to receive(:search).with(hash_including(device: 'mobile'))
      client.extract_link(link, device: 'mobile')
    end

    it 'ignores an api_key embedded in the link' do
      params = sent_params { client.extract_link("#{link}&api_key=link_key") }
      expect(params[:api_key]).to eq('dummy_secret_key')
      expect(params.keys.map(&:to_s).count('api_key')).to eq(1)
    end

    it 'replaces link parameters with string-keyed overrides' do
      params = sent_params { client.extract_link(link, 'device' => 'mobile') }
      expect(params.select { |key, _| key.to_s == 'device' }).to eq(device: 'mobile')
    end

    it 'keeps the extract engine when overrides set another engine' do
      params = sent_params { client.extract_link(link, engine: 'google') }
      expect(params.select { |key, _| key.to_s == 'engine' }).to eq(engine: 'extract')
    end

    it 'rejects links without a url' do
      expect { client.extract_link('https://serpapi.com/search.json?engine=extract') }
        .to raise_error(SerpApi::SerpApiError, /url parameter is required/)
    end

    it 'rejects non serpapi.com links' do
      expect { client.extract_link('https://evil.com/search.json?engine=extract') }
        .to raise_error(SerpApi::SerpApiError, /must be a serpapi\.com URL/)
    end

    it 'rejects links targeting another engine' do
      expect { client.extract_link('https://serpapi.com/search.json?engine=google&q=coffee') }
        .to raise_error(SerpApi::SerpApiError, /does not target the extract engine/)
    end
  end
end
