require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe "SerpApi client basic test" do

  before(:all) do
    @search = SerpApi::Client.new(engine: "google", api_key: ENV['API_KEY'])
  end

  it 'search' do
    json = @search.search(q: "Coffee", location: "Austin, TX")
    expect(json.size).to be > 7
    expect(json.class).to be Hash
    expect(json.keys.size).to be > 5
  end

  it 'html' do
    data = @search.html(q: "Coffee")
    expect(data).to match /coffee/i
  end

end
