require 'spec_helper'

# SerpApi returns searches with empty results and pages that can't be extracted as HTTP 200
# with a top-level `error` message. Only the HTTP status decides whether a request failed,
# so the client raises only for non-200 responses.
# see: https://serpapi.com/api-status-and-error-codes
describe 'JSON error handling' do
  let(:socket) { double }
  let(:client) { SerpApi::Client.new(api_key: 'test-key', engine: 'google') }

  let(:empty_results) do
    {
      search_metadata: { id: '6935c0b9a0cb1015d74ef919', status: 'Success', created_at: '2025-12-07 18:00:57 UTC' },
      search_information: { organic_results_state: 'Fully empty' },
      error: "Google hasn't returned any results for this query."
    }
  end

  let(:failed_search) do
    {
      search_metadata: { id: '64c32cfeb68f8bc186aaa013', status: 'Error' },
      error: "We couldn't get valid results for this search. Please try again later."
    }
  end

  def json_response(status, body)
    raw_response(status, JSON.generate(body), 'application/json; charset=utf-8')
  end

  def raw_response(status, body, content_type)
    double(status: status, body: body, headers: { 'Content-Type' => content_type }, flush: nil)
  end

  before do
    allow(HTTP).to receive(:timeout).and_return(double(persistent: socket))
  end

  describe 'searches with empty results' do
    it 'returns search results with the error key instead of raising' do
      allow(socket).to receive(:get).with('/search', anything).and_return(json_response(200, empty_results))

      expect(client.search(q: 'no results')).to eq(empty_results)
    end

    it 'returns archived search results with the error key instead of raising' do
      allow(socket).to receive(:get)
        .with('/searches/6935c0b9a0cb1015d74ef919.json', anything)
        .and_return(json_response(200, empty_results))

      results = client.search_archive('6935c0b9a0cb1015d74ef919')

      expect(results[:error]).to eq("Google hasn't returned any results for this query.")
      expect(results[:search_metadata][:created_at]).to eq('2025-12-07 18:00:57 UTC')
    end

    it 'returns search results with string keys' do
      allow(socket).to receive(:get).with('/search', anything).and_return(json_response(200, empty_results))

      results = client.search(q: 'no results', symbolize_names: false)

      expect(results['error']).to eq("Google hasn't returned any results for this query.")
    end
  end

  describe 'extractions without content' do
    let(:failed_extraction) do
      {
        search_metadata: { id: '6afd930b40fad414752692cc', status: 'Success' },
        search_parameters: { engine: 'extract', url: 'https://httpbin.org/status/404', device: 'desktop' },
        error: 'Unsupported content: the URL did not return an HTML document.'
      }
    end

    it 'returns extraction results with the error key instead of raising' do
      allow(socket).to receive(:get).with('/search', anything).and_return(json_response(200, failed_extraction))

      expect(client.extract(url: 'https://httpbin.org/status/404')).to eq(failed_extraction)
    end
  end

  describe 'HTTP 200 responses with search_metadata.status Error' do
    it 'returns them instead of raising' do
      allow(socket).to receive(:get)
        .with('/searches/64c32cfeb68f8bc186aaa013.json', anything)
        .and_return(json_response(200, failed_search))

      expect(client.search_archive('64c32cfeb68f8bc186aaa013')).to eq(failed_search)
    end

    it 'returns them with string keys' do
      allow(socket).to receive(:get).with('/search', anything).and_return(json_response(200, failed_search))

      results = client.search(q: 'coffee', symbolize_names: false)

      expect(results['search_metadata']['status']).to eq('Error')
      expect(results['error']).to eq(failed_search[:error])
    end
  end

  describe 'HTTP 200 responses that are not valid JSON' do
    it 'raises a JSON parse error' do
      allow(socket).to receive(:get).with('/search', anything)
        .and_return(raw_response(200, '{"search_metadata": {"id": "6935c0b9a0cb1015d74ef919"', 'application/json; charset=utf-8'))

      expect {
        client.search(q: 'coffee')
      }.to raise_error(SerpApi::SerpApiError, /\AJSON parse error: /) do |error|
        expect(error.response_status).to eq(200)
        expect(error.decoder).to eq(:json)
      end
    end

    it 'raises a JSON parse error when the body does not match its charset' do
      body = String.new(JSON.generate(error: "We\u2019re having trouble"), encoding: Encoding::US_ASCII)
      allow(socket).to receive(:get).with('/search', anything).and_return(raw_response(200, body, 'application/json; charset=us-ascii'))

      expect {
        client.search(q: 'coffee')
      }.to raise_error(SerpApi::SerpApiError, /\AJSON parse error: /)
    end
  end

  describe 'non-200 responses' do
    it 'raises with the error details' do
      allow(socket).to receive(:get).with('/search', anything).and_return(json_response(503, failed_search))

      expect {
        client.search(q: 'coffee')
      }.to raise_error(SerpApi::SerpApiError, /\AHTTP request failed with status: 503 error: We couldn't get valid results/) do |error|
        expect(error.serpapi_error).to eq(failed_search[:error])
        expect(error.search_id).to eq('64c32cfeb68f8bc186aaa013')
        expect(error.response_status).to eq(503)
      end
    end

    it 'raises with the error details with string keys' do
      allow(socket).to receive(:get).with('/search', anything).and_return(json_response(503, failed_search))

      expect {
        client.search(q: 'coffee', symbolize_names: false)
      }.to raise_error(SerpApi::SerpApiError) do |error|
        expect(error.serpapi_error).to eq(failed_search[:error])
        expect(error.search_id).to eq('64c32cfeb68f8bc186aaa013')
      end
    end

    it 'raises SerpApiError when the error and search id are not strings' do
      body = { search_metadata: { id: 123 }, error: { code: 500, message: 'boom' } }
      allow(socket).to receive(:get).with('/search', anything).and_return(json_response(500, body))

      expect {
        client.search(q: 'coffee')
      }.to raise_error(SerpApi::SerpApiError) do |error|
        expect(error.serpapi_error).to include('boom')
        expect(error.search_id).to eq('123')
      end
    end

    # e.g. an error page from Cloudflare, in front of SerpApi
    it 'raises with the status when the body is not JSON' do
      allow(socket).to receive(:get).with('/search', anything)
        .and_return(raw_response(502, 'error code: 502', 'text/plain; charset=UTF-8'))

      expect {
        client.search(q: 'coffee')
      }.to raise_error(SerpApi::SerpApiError, %r{\AHTTP request failed with status: 502 from url: https://serpapi.com/search\z}) do |error|
        expect(error.serpapi_error).to be_nil
        expect(error.response_status).to eq(502)
      end
    end

    # HTTP.rb tags the body with the charset from Content-Type, and JSON.parse converts it to UTF-8
    it 'raises with the status when the body does not match its charset' do
      body = String.new("<html>We\u2019re having trouble</html>", encoding: Encoding::US_ASCII)
      allow(socket).to receive(:get).with('/search', anything).and_return(raw_response(502, body, 'text/html; charset=us-ascii'))

      expect {
        client.search(q: 'coffee')
      }.to raise_error(SerpApi::SerpApiError, %r{\AHTTP request failed with status: 502 from url: https://serpapi.com/search\z}) do |error|
        expect(error.serpapi_error).to be_nil
      end
    end

    it 'raises without an error key' do
      allow(socket).to receive(:get).with('/account', anything).and_return(json_response(500, {}))

      expect {
        client.account
      }.to raise_error(SerpApi::SerpApiError, %r{\AHTTP request failed with status: 500 from url: https://serpapi.com/account\z}) do |error|
        expect(error.serpapi_error).to be_nil
        expect(error.response_status).to eq(500)
      end
    end
  end
end
