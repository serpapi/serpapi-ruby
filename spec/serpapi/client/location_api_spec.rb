require 'spec_helper'

describe 'SerpApi Location API' do
  it 'Get normalized location for Austin, TX' do
    client = SerpApi::Client.new(api_key: ENV['SERPAPI_KEY'])
    location_list = client.location(q: 'Austin, TX', limit: 3)
    expect(location_list.size).to eq(1)

    first = location_list.first
    expect(first[:id]).not_to be_nil
    expect(first[:name]).to eq('Austin, TX')
    expect(first[:country_code]).to eq('US')
    expect(first[:target_type]).to eq('DMA Region')
    expect(first[:gps]).to eq([-97.7430608, 30.267153])
    expect(first[:keys]).to eq(%w[austin tx texas united states])
    expect(first[:canonical_name]).to eq('Austin,TX,Texas,United States')
  end
end
