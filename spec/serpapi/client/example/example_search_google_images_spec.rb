require 'spec_helper'

describe 'search google images' do
  it 'prints images_results' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_images')
    results = client.search({
      "engine": "google",
      "tbm": "isch",
      "q": "coffee"
    })
    expect(results[:images_results]).not_to be_nil
    # pp results[:images_results]
    # ENV['API_KEY'] captures the secret user API available from http://serpapi.com
  end
end
