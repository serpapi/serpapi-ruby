require 'spec_helper'

describe 'Extract API' do
  let(:client) { SerpApi::Client.new(api_key: 'dummy_secret_key', persistent: false) }

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
