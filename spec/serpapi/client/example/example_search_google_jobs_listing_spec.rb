require 'spec_helper'

describe 'example: google_jobs_listing search' do
  it 'prints apply_options' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_jobs_listing', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      q: 'eyJqb2JfdGl0bGUiOiJCYXJpc3RhIiwiaHRpZG9jaWQiOiJ5Vy1laV9FQ3Y3Z0FBQUFBQUFBQUFBPT0iLCJnbCI6InVzIiwiaGwiOiJlbiIsImZjIjoiRXZjQkNyY0JRVUYwVm14aVJETmtXVmxsYm5SNVNqZFVNM3BEVkd0d1drcFdZVXRzTTNOQmFIaHVPVEpXWWsxbGVsRldiMGxYVjBWdUxVdzNYMlF5V0VKTVpEaDRMVkZ6Umtwek5qSklaRkJtVTJReU5FbGxZa0ZDWnpCemVUY3lYemc1UkU5blNIWlpRVnBRU1doMFJHMXljRk50VkhCemJsOUxjbUprYURKNU4ybE5hMmt5Vmpkc2RuUmpORnB3VkcwemEzUmFTV3RZYWxGcmFHRjJkek0yTVcxeGNGbGliM2xCWmtveVl6ZDJRMTlrYTB0alYzQkpjbVZ2RWhkSVNHVnNXVFpFY2toTU1tOXhkSE5RYms1MVIzRkJaeG9pUVVSVmVVVkhaV2xpVmxaaVgxRnRkbXRrVmpaVWQxVnVhbWsxYW5KT2QyaE9adyIsImZjdiI6IjMiLCJmY19pZCI6ImZjXzEiLCJhcHBseV9saW5rIjp7InRpdGxlIjoiLm5GZzJlYntmb250LXdlaWdodDo1MDB9LkJpNkRkY3tmb250LXdlaWdodDo1MDB9QXBwbHkgZGlyZWN0bHkgb24gSW5kZWVkIiwibGluayI6Imh0dHBzOi8vd3d3LmluZGVlZC5jb20vdmlld2pvYj9qaz03ZTA0YWYyNmIyZGE2NjljXHUwMDI2dXRtX2NhbXBhaWduPWdvb2dsZV9qb2JzX2FwcGx5XHUwMDI2dXRtX3NvdXJjZT1nb29nbGVfam9ic19hcHBseVx1MDAyNnV0bV9tZWRpdW09b3JnYW5pYyJ9fQ'
    })
    expect(results[:apply_options]).not_to be_nil, "No apply options found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:apply_options]
    # doc: http://serpapi.com/google-jobs-listing-api
  end
end
