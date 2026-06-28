require 'spec_helper'

describe 'SerpApi Search Archive API error handling' do
  def client_with_response(body, status)
    response = double('response', body: body, status: status)
    client = SerpApi::Client.new(api_key: '', engine: 'google', persistent: false)

    allow(client).to receive(:execute_request).and_return(response)
    client
  end

  def client_with_json(payload, status)
    client_with_response(JSON.dump(payload), status)
  end

  it 'returns archived search data when a successful response contains an error field' do
    payload = {
      error: "Google hasn't returned any results for this query.",
      search_metadata: {
        id: '6935c0b9a0cb1015d74ef919'
      }
    }
    client = client_with_json(payload, 200)

    expect(client.search_archive(payload[:search_metadata][:id])).to eq(payload)
  end

  it 'keeps raising for regular search responses with an error field' do
    payload = {
      error: 'Missing query `q` parameter.',
      search_metadata: {
        id: 'regular-search-error'
      }
    }
    client = client_with_json(payload, 200)

    expect {
      client.search(q: 'Coffee')
    }.to raise_error(SerpApi::SerpApiError) { |error|
      expect(error.response_status).to eq(200)
      expect(error.serpapi_error).to eq(payload[:error])
    }
  end

  it 'raises for unsuccessful archive responses with an error field' do
    payload = {
      error: 'Search not found.',
      search_metadata: {
        id: 'missing-archive-search'
      }
    }
    client = client_with_json(payload, 404)

    expect {
      client.search_archive(payload[:search_metadata][:id])
    }.to raise_error(SerpApi::SerpApiError) { |error|
      expect(error.response_status).to eq(404)
      expect(error.serpapi_error).to eq(payload[:error])
      expect(error.search_id).to eq(payload[:search_metadata][:id])
    }
  end

  it 'raises for unsuccessful archive responses without an error field' do
    payload = {
      search_metadata: {
        id: 'server-error-archive-search'
      }
    }
    client = client_with_json(payload, 500)

    expect {
      client.search_archive(payload[:search_metadata][:id])
    }.to raise_error(SerpApi::SerpApiError) { |error|
      expect(error.response_status).to eq(500)
      expect(error.serpapi_error).to be_nil
      expect(error.search_id).to eq(payload[:search_metadata][:id])
    }
  end

  it 'still raises parser errors for malformed archive JSON responses' do
    client = client_with_response('{"error":', 200)

    expect {
      client.search_archive('malformed-json')
    }.to raise_error(SerpApi::SerpApiError, /JSON parse error/)
  end
end
