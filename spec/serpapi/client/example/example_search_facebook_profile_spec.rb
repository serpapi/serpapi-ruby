require 'spec_helper'

describe 'example: facebook_profile search' do
  it 'prints profile_results' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'facebook_profile', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      profile_id: 'Modernatx'
    })
    expect(results[:profile_results]).not_to be_nil, "No profile results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:profile_results]
    # doc: http://serpapi.com/facebook-profile-api
  end
end
