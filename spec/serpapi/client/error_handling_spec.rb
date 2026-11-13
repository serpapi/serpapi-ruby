require 'spec_helper'

# SerpApi returns searches with empty results as HTTP 200 with `search_metadata.status: Success`
# and a top-level `error` message. Only non-200 responses and `search_metadata.status: Error` are failures.
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
    double(
      status: status,
      body: JSON.generate(body),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      flush: nil
    )
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

  describe 'failed searches' do
    it 'raises when search_metadata.status is Error with HTTP 200' do
      allow(socket).to receive(:get)
        .with('/searches/64c32cfeb68f8bc186aaa013.json', anything)
        .and_return(json_response(200, failed_search))

      expect {
        client.search_archive('64c32cfeb68f8bc186aaa013')
      }.to raise_error(SerpApi::SerpApiError, /\ASearch failed with status: Error error: We couldn't get valid results/) do |error|
        expect(error.serpapi_error).to eq(failed_search[:error])
        expect(error.search_id).to eq('64c32cfeb68f8bc186aaa013')
        expect(error.response_status).to eq(200)
      end
    end

    it 'raises when search_metadata.status is Error with string keys' do
      allow(socket).to receive(:get).with('/search', anything).and_return(json_response(200, failed_search))

      expect {
        client.search(q: 'coffee', symbolize_names: false)
      }.to raise_error(SerpApi::SerpApiError) do |error|
        expect(error.serpapi_error).to eq(failed_search[:error])
        expect(error.search_id).to eq('64c32cfeb68f8bc186aaa013')
      end
    end

    it 'raises for non-200 responses' do
      allow(socket).to receive(:get).with('/search', anything).and_return(json_response(503, failed_search))

      expect {
        client.search(q: 'coffee')
      }.to raise_error(SerpApi::SerpApiError, /\AHTTP request failed with status: 503 error: We couldn't get valid results/) do |error|
        expect(error.serpapi_error).to eq(failed_search[:error])
        expect(error.search_id).to eq('64c32cfeb68f8bc186aaa013')
        expect(error.response_status).to eq(503)
      end
    end

    it 'raises for non-200 responses without an error key' do
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
