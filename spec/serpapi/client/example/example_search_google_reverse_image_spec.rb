require 'spec_helper'

describe 'example: google_reverse_image search' do
  it 'prints image_sizes' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_reverse_image')
    results = client.search({
      'image_url': 'https://i.imgur.com/5bGzZi7.jpg'
    })
    expect(results[:image_sizes]).not_to be_nil
    # pp results[:image_sizes]
    # ENV['API_KEY'] captures the secret user API available from http://serpapi.com
  end
end
