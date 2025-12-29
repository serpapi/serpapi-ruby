require 'spec_helper'

describe 'example: google_ads_transparency_center_ad_details search' do
  it 'prints organic_results' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_ads_transparency_center_ad_details', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      advertiser_id: 'AR12039459359856525313',
      creative_id: 'CR12192089750093430785'
    })
    expect(results[:organic_results]).not_to be_nil, "No organic results found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:organic_results]
    # doc: http://serpapi.com/google-ads-transparency-center-ad-details-api
  end
end
