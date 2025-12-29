require 'spec_helper'

describe 'example: google_scholar_author search' do
  it 'prints author' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_scholar_author', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      author_id: 'LSsXyncAAAAJ',
      view_op: 'view_citation',
      citation_id: 'LSsXyncAAAAJ:9yKSN-GCB0IC'
    })
    expect(results[:author]).not_to be_nil, "No author found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:author]
    # doc: http://serpapi.com/google-scholar-author-api
  end
end
