require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe 'SerpApi Location API' do
  it 'get normalized location for Austin, TX' do
    client = SerpApi::Client.new
    location_list = client.location(q: 'Austin', limit: 3)
    expect(location_list.size).to eq(3)

    first = location_list.first
    expect(first[:id]).to eq('585069bdee19ad271e9bc072')
    expect(first[:name]).to eq('Austin, TX')
    expect(first[:country_code]).to eq('US')
    expect(first[:target_type]).to eq('DMA Region')
    expect(first[:reach]).to eq(5_560_000)
    expect(first[:gps]).to eq([-97.7430608, 30.267153])
    expect(first[:keys]).to eq(%w[austin tx texas united states])
    expect(first[:canonical_name]).to eq('Austin,TX,Texas,United States')

    if client.engine == 'google'
      expect(first[:google_id]).to eq(200_635)
      expect(first[:google_parent_id]).to eq(21_176)
    end
  end
end
