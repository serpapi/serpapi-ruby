require_relative 'offline_helper'

# Offline regression specs. Each block documents the bug it locks down.
RSpec.describe SerpApi::Client do
  let(:api_key) { 'test_secret_key_1234567890' }

  def stub_search(body:, status: 200, query: hash_including({}))
    stub_request(:get, "#{SERPAPI_BACKEND}/search")
      .with(query: query)
      .to_return(status: status, body: body, headers: { 'Content-Type' => 'application/json' })
  end

  describe 'timeout in persistent mode' do
    # Regression: `.persistent` used to be called without `.timeout`, so the
    # documented `timeout:` option was silently ignored on the default path.
    it 'attaches the configured timeout to the persistent socket' do
      client = described_class.new(api_key: api_key, engine: 'google', timeout: 7, persistent: true)
      expect(client.socket.default_options.timeout_options.values).to include(7)
    ensure
      client&.close
    end
  end

  describe 'symbolize_names resolution' do
    let(:json) { '{"search_metadata":{"id":"abc"},"organic_results":[{"title":"Coffee"}]}' }

    # Regression: the flag was read from per-call params only, so a
    # constructor-level setting had no effect.
    it 'honors symbolize_names:false set on the constructor' do
      stub_search(body: json)
      client = described_class.new(api_key: api_key, engine: 'google', persistent: false, symbolize_names: false)
      results = client.search(q: 'coffee')
      expect(results.keys).to include('search_metadata')
      expect(results.keys).not_to include(:search_metadata)
    end

    it 'lets a per-call symbolize_names override the constructor default' do
      stub_search(body: json)
      client = described_class.new(api_key: api_key, engine: 'google', persistent: false, symbolize_names: false)
      results = client.search(q: 'coffee', symbolize_names: true)
      expect(results.keys).to include(:search_metadata)
    end

    it 'defaults to symbolized keys' do
      stub_search(body: json)
      client = described_class.new(api_key: api_key, engine: 'google', persistent: false)
      expect(client.search(q: 'coffee').keys).to include(:search_metadata)
    end
  end

  describe 'caller hash is never mutated' do
    # Regression: the constructor deleted :timeout/:persistent from the
    # caller's own hash before cloning.
    it 'leaves :timeout and :persistent in the caller-provided hash' do
      input = { api_key: api_key, engine: 'google', timeout: 5, persistent: false }
      described_class.new(input)
      expect(input).to include(timeout: 5, persistent: false)
    end
  end

  describe 'client-only options are not sent to the backend' do
    it 'sends q + source but never symbolize_names' do
      stub = stub_search(
        body: '{"ok":true}',
        query: hash_including('q' => 'coffee', 'source' => "serpapi-ruby:#{SerpApi::VERSION}")
      )
      client = described_class.new(api_key: api_key, engine: 'google', persistent: false, symbolize_names: false)
      client.search(q: 'coffee')

      expect(stub).to have_been_requested
      expect(
        a_request(:get, "#{SERPAPI_BACKEND}/search").with(query: hash_including('symbolize_names'))
      ).not_to have_been_made
    end
  end

  describe 'html search' do
    it 'returns the raw HTML body as a String' do
      stub_search(body: '<html><body>fresh coffee</body></html>')
      client = described_class.new(api_key: api_key, engine: 'google', persistent: false)
      html = client.html(q: 'coffee')
      expect(html).to be_a(String)
      expect(html).to match(/coffee/i)
    end
  end

  describe 'error handling' do
    let(:archive_url) { "#{SERPAPI_BACKEND}/searches/abc123.json" }

    it 'raises on a non-200 response (transport error)' do
      stub_search(status: 400, body: '{"error":"Missing query `q` parameter."}')
      client = described_class.new(api_key: api_key, engine: 'google', persistent: false)
      expect { client.search({}) }.to raise_error(SerpApi::SerpApiError, /status: 400.*Missing query/m)
    end

    it 'raises by default on a 200 with an error field for a live search' do
      stub_search(status: 200, body: '{"error":"Google hasn\'t returned any results for this query."}')
      client = described_class.new(api_key: api_key, engine: 'google', persistent: false)
      expect { client.search(q: 'zzz') }.to raise_error(SerpApi::SerpApiError, /returned any results/)
    end

    # Issue #17: an archived search that recorded an error must be readable,
    # not raised, when the HTTP status is 200.
    it 'does NOT raise for an archived 200+error by default' do
      stub_request(:get, archive_url).with(query: hash_including({})).to_return(
        status: 200,
        body: '{"error":"Google hasn\'t returned any results for this query.","search_metadata":{"id":"abc123"}}'
      )
      client = described_class.new(api_key: api_key, engine: 'google', persistent: false)
      result = client.search_archive('abc123')
      expect(result[:error]).to match(/returned any results/)
      expect(result.dig(:search_metadata, :id)).to eq('abc123')
    end

    it 'still raises for an archived error when raise_on_search_error: true' do
      stub_request(:get, archive_url).with(query: hash_including({})).to_return(status: 200, body: '{"error":"nope"}')
      client = described_class.new(api_key: api_key, engine: 'google', persistent: false)
      expect { client.search_archive('abc123', raise_on_search_error: true) }
        .to raise_error(SerpApi::SerpApiError)
    end

    it 'raises a parser error on a non-JSON body' do
      stub_search(body: '<html>not json</html>')
      client = described_class.new(api_key: api_key, engine: 'google', persistent: false)
      expect { client.search(q: 'coffee') }.to raise_error(SerpApi::SerpApiError, /JSON parse error/)
    end
  end

  describe 'SerpApiError#to_h' do
    it 'exposes structured error context' do
      stub_search(status: 401, body: '{"error":"Invalid API key"}')
      client = described_class.new(api_key: 'bad', engine: 'google', persistent: false)
      client.search(q: 'coffee')
    rescue SerpApi::SerpApiError => e
      expect(e.to_h).to include(response_status: 401, serpapi_error: 'Invalid API key', decoder: :json)
    end
  end
end
