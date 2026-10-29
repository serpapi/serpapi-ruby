require 'spec_helper'

describe 'example: extract' do
  it 'extracts structured data from a web page' do
    # initialize the serp api client
    client = SerpApi::Client.new(api_key: api_key)
    # extract a single page using the serpapi extract engine
    results = client.extract(url: 'https://example.com/')
    expect(results[:page_information]).not_to be_nil, "No page information found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:page_information]
    # doc: https://serpapi.com/extract-api
  end

  it 'maps same-origin urls of a website' do
    client = SerpApi::Client.new(api_key: api_key)
    results = client.extract(url: 'https://books.toscrape.com/', mode: 'map')
    expect(results[:urls]).not_to be_nil, "No urls found! keys available: #{results.keys}"
  end

  it 'crawls a website and returns parsed pages' do
    client = SerpApi::Client.new(api_key: api_key)
    results = client.extract(url: 'https://books.toscrape.com/', mode: 'crawl', max_pages: 2, max_depth: 1)
    expect(results[:pages]).not_to be_nil, "No pages found! keys available: #{results.keys}"
  end
end
