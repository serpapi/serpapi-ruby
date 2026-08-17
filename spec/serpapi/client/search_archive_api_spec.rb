require 'spec_helper'

describe 'SerpApi Search Archive API' do
  it 'fetch a search result from the archive' do
    # mock
    search_response_mock = {
      search_metadata: {
        id: "cdbdbdebeabab1beb"
      }
    }

    # search
    client = SerpApi::Client.new(api_key: ENV['SERPAPI_KEY'] || '', engine: 'google')
    if client.api_key.empty?
      allow(client).to receive(:search) { search_response_mock }
    end
    results = client.search(q: 'Coffee', location: 'Portland')

    search_id = results[:search_metadata][:id]
    expect(search_id).not_to be_empty
    archive_search = results

    # search archive
    if client.api_key
      # retrieve search from archive
      client = SerpApi::Client.new(api_key: client.api_key, engine: 'google')
      results = client.search_archive(search_id)
      expect(archive_search).to eq(results)
    else
      client = SerpApi::Client.new(api_key: client.api_key, engine: 'google')
      allow(client).to receive(:get) { search_response_mock }
      expect(archive_search).to eq(results)
    end
  end

  it 'fetches an archived search as Markdown' do
    client = SerpApi::Client.new(api_key: ENV['SERPAPI_KEY'], engine: 'google')
    response = double(status: 200, body: "---\n## Organic Results\n", flush: :clean)

    expect(client.socket).to receive(:get)
      .with('/searches/search-id.md', params: hash_including(api_key: ENV['SERPAPI_KEY']))
      .and_return(response)

    results = client.search_archive('search-id', :markdown)
    expect(results).to eq("---\n## Organic Results\n")
  end
end
