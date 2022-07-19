describe 'search google jobs' do
  xit 'prints jobs_results' do
    client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_jobs')
    results = client.search({
      "q": "coffee"
    })
    expect(results[:jobs_results]).not_to be_nil
    # pp results[:jobs_results]
    # ENV['API_KEY'] captures the secret user API available from http://serpapi.com
  end
end
