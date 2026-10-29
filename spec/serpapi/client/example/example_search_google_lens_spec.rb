require 'spec_helper'

describe 'example: google_lens search' do
  it 'prints visual_matches' do
    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_lens', api_key: api_key)
    # run a search using serpapi service
    results = client.search(
      url: 'https://i.imgur.com/HBrB8p0.png'
    )
    expect(results[:visual_matches]).not_to be_nil, "No visual matches found! keys available: #{results.keys}"
    expect(results[:visual_matches]).not_to be_empty, 'No visual matches returned!'

    # print the output of the response in formatted JSON
    # pp results[:visual_matches]
    # doc: https://serpapi.com/google-lens-api
  end
end
