# Scrape Google and other search engines from our fast, easy, and complete API using SerpApi.com
#
[![serpapi-ruby](https://github.com/serpapi/serpapi-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/serpapi/serpapi-ruby/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/serpapi.svg)](https://badge.fury.io/rb/serpapi)

This ruby library is meant to scrape and parse results from all major search engine available world wide including Google, Bing, Baidu, Yandex, Yahoo, Ebay, Apple and more using [SerpApi](https://serpapi.com).

SerpApi.com provides a [script builder](https://serpapi.com/demo) to get you started quickly.

## Installation

A modern version of Ruby must be already installed.

```bash
$ gem install serpapi
```

[Link to the gem page](https://rubygems.org/gems/serpapi/)

Tested Ruby versions:
 - 2.2
 - 2.5.2
 - 3.0.0

see: Git hub actions.

## Quick start

```ruby
require 'serpapi'
client = SerpApi::Client.new(engine: 'google', api_key: "secret_api_key")
results = client.search(q: "coffee")
pp results
 ```

This example runs a client about "coffee" using your secret api key 
 and get a result in dynamic Hash.

The SerpApi.com service (backend)
 - searches on Google using the client: q = "coffee"
 - parses the messy HTML responses
 - return a standardizes JSON response
The class SerpApi::Client
 - Format the request to SerpApi.com server
 - Execute GET http request
 - Parse JSON into Ruby Hash using JSON standard library provided by Ruby
Et voila..

See the [playground to generate your code.](https://serpapi.com/playground)

### Summary
- [Installation](#installation)
- [Quick start](#quick-start)
- [API Guide](#guide)
  - [Search API overview](#search-api-overview)
  - [Example by specification](#example-by-specification)
  - [Location API](#location-api)
  - [Search Archive API](#client-archive-api)
  - [Account API](#account-api)'
- [Basic example per search engine](#basic-example-per-search-engine)
  - [Search Google Images](#search-google-images)
- [Advanced search API usage](#advanced-search-api-usage)
  - [SerpApi client](#serpapi-client)
  - [Batch Asynchronous client](#batch-asynchronous-client)
- [Change log](#change-log)
- [Roadmap](#roadmap)
- [Conclusion](#conclusion)
- [Contributing](#contributing)

## API Guide

### Search API overview
```ruby
# initialize the client
client = SerpApi::Client.new(api_key: "private key")

# search query
query = {
  engine: "google", # full list: https://serpapi.com/search-api
  q: "client",
  google_domain: "Google Domain",
  location: "Location Requested", # example: Portland,Oregon,United States
  device: "desktop|mobile|tablet",
  hl: "Google UI Language",
  gl: "Google Country",
  safe: "Safe Search Flag",
  num: "Number of Results",
  start: "Pagination Offset",
  tbm: "nws|isch|shop",
  tbs: "custom to be client criteria"
  async: true|false # allow async call
}

# formated search results as a Hash
#  serpapi.com converts HTML -> JSON 
results = client.search(query)

# raw html as a String
#  serpapi.com acts a proxy to provive high throughputs
doc = client.html(query)
```

(The full documentation)[https://serpapi.com/client-api].
More hands on examples are available belows.


### Location API

```ruby
client = SerpApi::Client.new() 
location_list = client.location(q: "Austin", limit: 3)
puts "number of location: #{location_list.size}"
pp location_list
```

it prints the first 3 location matching Austin (Texas, Texas, Rochester)
```ruby
[{:id=>"585069bdee19ad271e9bc072",
  :google_id=>200635,
  :google_parent_id=>21176,
  :name=>"Austin, TX",
  :canonical_name=>"Austin,TX,Texas,United States",
  :country_code=>"US",
  :target_type=>"DMA Region",
  :reach=>5560000,
  :gps=>[-97.7430608, 30.267153],
  :keys=>["austin", "tx", "texas", "united", "states"]},
  ...]
```

### Search Archive API

This API allows to retrieve previous client.
To do so run a client to save a search_id.
```ruby
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google')
original_search = client.search(q: "Coffee", location: "Portland")
search_id = original_search[:search_metadata][:id]
```

Now let retrieve the previous client from the archive.

```ruby
client = SerpApi::Client.new(api_key: ENV['API_KEY'])
archive_search = client.search_archive(search_id)
pp archive_search
```
it prints the client from the archive.

### Account API
```ruby
client = SerpApi::Client.new(api_key: ENV['API_KEY'])
pp client.account
```
it prints your account information.

## Basic example per search engine
### Search Google Images
```ruby
    client = SerpApi::Client.new(tbm: 'isch', api_key: ENV['API_KEY'], engine: 'google')
    image_results_list = client.search(q: 'coffee')[:images_results]
    image_results_list[0..2].each do |image_result|
      puts image_result[:original]
    end
```
 see: spec/serpapi/example_search_google_images_spec.rb

This code prints the first 3 images links.
To download the image on Linux you could do: `wget #{image_result[:original]}`

### Search youtube
```ruby
    client = SerpApi::Client.new(api_key: ENV['API_KEY'])
    query = {
      engine: "youtube",
      search_query: "Coffee"
    }
    hash = client.search(query)
    hash[:video_results][0..2].each do |video|
      puts video[:link]
    end
  end
end
```
 see: spec/serpapi/example_search_youtube_spec.rb

## Advanced search API usage

### Batch Asynchronous client

Search API enables to search `async`.
 - Non-blocking - async=true : more complex code but 
 - Blocking - async=false - it's more compute intensive because the client would need to hold many connections.

```ruby
# MAANG company
company_list = %w(meta amazon apple netflix google)
client = SerpApi::Client.new({async: true, api_key: "secret_api_key"})
search_queue = Queue.new
company_list.each do |company|
  # set client
  client.parameter[:q] = company

  # store request into a search_queue - no-blocker
  result = client.search()
  if result[:search_metadata][:status] =~ /Cached|Success/
    puts "#{company}: client done"
    next
  end

  # add result to the client queue
  search_queue.push(result)
end

puts "wait until all searches are cached or success"
client = SerpApi::Client.new
while !search_queue.empty?
  result = search_queue.pop
  # extract client id
  search_id = result[:search_metadata][:id]

  # retrieve client from the archive - blocker
  search_archived = client.search_archive(search_id)
  if search_archived[:search_metadata][:status] =~ /Cached|Success/
    puts "#{search_archived[:search_parameters][:q]}: client done"
    next
  end

  # add result to the client queue
  search_queue.push(result)
end

search_queue.close
puts 'all searches completed'
  ```
This code shows a simple implementation to run a batch of asynchronously searches.

## Change log
 * [2022-03-20] 1.0.0 Full API support

## Developer

We love true open source, continuous integration and Test Drive Development (TDD).
 We are using RSpec to test [our infrastructure around the clock]) using github action in order to achieve the best QoS (Quality Of Service).

The directory spec/ includes specification which serves dual purpose of examples and functional tests.

Set your api key to allow the tests to run.
```bash
export API_KEY="your secret key"
```

Install testing dependency
```bash
gem install rspec
```

To run the test:
```bash
rspec test
```

or if you prefer Rake
```bash
rake test
```

Contributions are welcome, feel to submit a pull request!

