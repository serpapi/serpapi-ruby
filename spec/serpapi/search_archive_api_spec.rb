require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe 'SerpApi Search Archive API' do
  it 'fetch a search result from the archive' do
    # mock
    search_response_mock = {
        search_metadata: {
          id: "cdbdbdebeabab1beb"
        }
      }
    client = SerpApi::Client.new(api_key: ENV['API_KEY'] || '', engine: 'google')
    if client.api_key.empty?
      allow(client).to receive(:search) { search_response_mock }
    end
    original_search = client.search(q: 'Coffee', location: 'Portland')

    search_id = original_search[:search_metadata][:id]
    expect(search_id).not_to be_empty

    if !client.api_key.empty?
      # retrieve search from archive
      client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google')
      if client.api_key.nil?
        allow(search).to receive(:get_results) { search_response_mock }
      end
      archive_search = client.search_archive(search_id)
      expect(archive_search).to eq(original_search)
    end
  end
end
