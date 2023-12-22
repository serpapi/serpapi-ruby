# SerpApi Ruby Library

[![Gem Version](https://badge.fury.io/rb/serpapi.svg)](https://badge.fury.io/rb/serpapi) [![serpapi-ruby](https://github.com/serpapi/serpapi-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/serpapi/serpapi-ruby/actions/workflows/ci.yml)  [![serpapi-ruby-alternative](https://github.com/serpapi/serpapi-ruby/actions/workflows/sanity_alt.yml/badge.svg)](https://github.com/serpapi/serpapi-ruby/actions/workflows/sanity_alt.yml) [![serpapi-ruby-sanity-1](https://github.com/serpapi/serpapi-ruby/actions/workflows/sanity_1.yml/badge.svg)](https://github.com/serpapi/serpapi-ruby/actions/workflows/sanity_1.yml) [![serpapi-ruby-sanity-2](https://github.com/serpapi/serpapi-ruby/actions/workflows/sanity_2.yml/badge.svg)](https://github.com/serpapi/serpapi-ruby/actions/workflows/sanity_2.yml)

Integrate search data into your Ruby application. This library is the official wrapper for SerpApi (https://serpapi.com).

SerpApi supports Google, Google Maps, Google Shopping, Baidu, Yandex, Yahoo, eBay, App Stores, and more.

## Installation

Ruby 1.9.3 (or more recent), JRuby 9.1.17 (or more recent), or TruffleRuby 19.3.0 (or more recent) is required.

### Bundler
```ruby
gem 'serpapi', '~> 1.0.0'
```

### Gem
```bash
$ gem install serpapi
```

[Ruby Gem page](https://rubygems.org/gems/serpapi/)

## Simple Usage

```ruby
require 'serpapi'
client = SerpApi::Client.new api_key: "serpapi_api_key"
results = client.search q: "coffee", engine: "google"
pp results
 ```

This example runs a search for "coffee" on Google. It then returns the results as a regular Ruby Hash. See the [playground](https://serpapi.com/playground) to generate your own code.

## Advanced Usage
### Search API
```ruby
# load gem
require 'serpapi'

# serpapi client created with default parameters
client = SerpApi::Client.new(api_key: "secret_key", engine: "google")

# We recommend that you keep your keys safe.
# At least, don't commit them in plain text.
# More about configuration via environment variables:
# https://hackernoon.com/all-the-secrets-of-encrypting-api-keys-in-ruby-revealed-5qf3t5l

# search query overview (more fields available depending on search engine)
params = {
  # select the search engine (full list: https://serpapi.com/)
  engine: "google",
  # actual search query
  q: "Coffee",
  # then adds search engine specific options.
  # for example: google specific parameters: https://serpapi.com/search-api
  google_domain: "Google Domain",
  location: "Location Requested", # example: Portland,Oregon,United States [see: Location API](#Location-API)
  device: "desktop|mobile|tablet",
  hl: "Google UI Language",
  gl: "Google Country",
  safe: "Safe Search Flag",
  num: "Number of Results",
  start: "Pagination Offset",
  tbm: "nws|isch|shop",
  tbs: "custom to be client criteria",
  # tweak HTTP client behavior
  async: false, # true when async call enabled.
  timeout: 60, # HTTP timeout in seconds on the client side only.
}

# formated search results as a Hash
#  serpapi.com converts HTML -> JSON
results = client.search(params)

# raw search engine html as a String
#  serpapi.com acts a proxy to provive high throughputs, no search limit and more.
raw_html = client.html(parameter)
```

[Google search documentation](https://serpapi.com/search-api).
More hands on examples are available below.

#### Documentations

 * [API documentation](https://rubydoc.info/github/serpapi/serpapi-ruby/master)
 * [Full documentation on SerpApi.com](https://serpapi.com)
 * [Library Github page](https://github.com/serpapi/serpapi-ruby)
 * [Library GEM page](https://rubygems.org/gems/serpapi/)
 * [API health status](https://serpapi.com/status)

### Location API

```ruby
require 'serpapi'
client = SerpApi::Client.new()
location_list = client.location(q: "Austin", limit: 3)
puts "number of location: #{location_list.size}"
pp location_list
```

it prints the first 3 locations matching Austin (Texas, Texas, Rochester)
```ruby
[{
  :id=>"585069bdee19ad271e9bc072",
  :google_id=>200635,
  :google_parent_id=>21176,
  :name=>"Austin, TX",
  :canonical_name=>"Austin,TX,Texas,United States",
  :country_code=>"US",
  :target_type=>"DMA Region",
  :reach=>5560000,
  :gps=>[-97.7430608, 30.267153],
  :keys=>["austin", "tx", "texas", "united", "states"]
  }
  # ...
]
```

NOTE: api_key is not required for this endpoint.

### Search Archive API

This API allows retrieving previous search results.
To fetch earlier results from the search_id.

First, you need to run a search and save the search id.
```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: 'secret_api_key', engine: 'google')
results = client.search(q: "Coffee", location: "Portland")
search_id = results[:search_metadata][:id]
```

Now let's retrieve the previous search results from the archive.

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: 'secret_api_key')
results = client.search_archive(search_id)
pp results
```

This code prints the search results from the archive. :)

### Account API

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: 'secret_api_key')
pp client.account
```

It prints your account information.

### Bulk Search API

If you have high volume of searches (e.g., >= 1 million) and they don't need to be live, you can use our Bulk Search API. You just have to use the `scheduled` parameter:

```ruby
client = SerpApi::Client.new api_key: 'secret_api_key', scheduled: true
searches = [
  { engine: "google", q: "coffee" },
  { engine: "google", q: "tea" },
  { engine: "google", q: "hot chocolate milk" },
  # ...
]
# Submit async searches
async_searches = searches.map do |search|
  async_search = client.search search
  async_search
end
# Get an ETA using the last search scheduled time
bulk_search_eta = async_search_results.last[:search_metadata][:scheduled_at]
# After the searches are done processing (i.e., `bulk_search_eta`)
async_search_results = async_searches.map do |search|
  results = client.search_archive search[:id]
  results
end
```

## Basic example per search engine

### Search Bing

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'bing')
results = client.search({
  'q': 'coffee'
})
pp results[:organic_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_bing_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_bing_spec.rb)
 * doc: [https://serpapi.com/bing-search-api](https://serpapi.com/bing-search-api)

### Search Baidu

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'baidu')
results = client.search({
  'q': 'coffee'
})
pp results[:organic_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_baidu_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_baidu_spec.rb)
 * doc: [https://serpapi.com/baidu-search-api](https://serpapi.com/baidu-search-api)

### Search Yahoo!

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'yahoo')
results = client.search({
  'p': 'coffee'
})
pp results[:organic_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_yahoo_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_yahoo_spec.rb)
 * doc: [https://serpapi.com/yahoo-search-api](https://serpapi.com/yahoo-search-api)

### Search YouTube

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'youtube')
results = client.search({
  'search_query': 'coffee'
})
pp results[:video_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_youtube_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_youtube_spec.rb)
 * doc: [https://serpapi.com/youtube-search-api](https://serpapi.com/youtube-search-api)

### Search Walmart

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'walmart')
results = client.search({
  'query': 'coffee'
})
pp results[:organic_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_walmart_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_walmart_spec.rb)
 * doc: [https://serpapi.com/walmart-search-api](https://serpapi.com/walmart-search-api)

### Search eBay

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'ebay')
results = client.search({
  '_nkw': 'coffee'
})
pp results[:organic_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_ebay_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_ebay_spec.rb)
 * doc: [https://serpapi.com/ebay-search-api](https://serpapi.com/ebay-search-api)

### Search Naver

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'naver')
results = client.search({
  'query': 'coffee'
})
pp results[:ads_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_naver_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_naver_spec.rb)
 * doc: [https://serpapi.com/naver-search-api](https://serpapi.com/naver-search-api)

### Search The Home Depot

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'home_depot')
results = client.search({
  'q': 'table'
})
pp results[:products]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_home_depot_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_home_depot_spec.rb)
 * doc: [https://serpapi.com/home-depot-search-api](https://serpapi.com/home-depot-search-api)

### Search Apple App Store

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'apple_app_store')
results = client.search({
  'term': 'coffee'
})
pp results[:organic_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_apple_app_store_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_apple_app_store_spec.rb)
 * doc: [https://serpapi.com/apple-app-store](https://serpapi.com/apple-app-store)

### Search DuckDuckGo

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'duckduckgo')
results = client.search({
  'q': 'coffee'
})
pp results[:organic_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_duckduckgo_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_duckduckgo_spec.rb)
 * doc: [https://serpapi.com/duckduckgo-search-api](https://serpapi.com/duckduckgo-search-api)

### Search Google Search

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_search')
results = client.search({
  "q": "coffee",
  "engine": "google"
})
pp results[:organic_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_google_search_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_google_search_spec.rb)
 * doc: [https://serpapi.com/search-api](https://serpapi.com/search-api)

### Search Google Scholar

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_scholar')
results = client.search({
  'q': 'coffee'
})
pp results[:organic_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_google_scholar_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_google_scholar_spec.rb)
 * doc: [https://serpapi.com/google-scholar-api](https://serpapi.com/google-scholar-api)

### Search Google Autocomplete

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_autocomplete')
results = client.search({
  'q': 'coffee'
})
pp results[:suggestions]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_google_autocomplete_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_google_autocomplete_spec.rb)
 * doc: [https://serpapi.com/google-autocomplete-api](https://serpapi.com/google-autocomplete-api)

### Search Google Product

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_product')
results = client.search({
  'q': 'coffee',
  'product_id': '4172129135583325756'
})
pp results[:product_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_google_product_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_google_product_spec.rb)
 * doc: [https://serpapi.com/google-product-api](https://serpapi.com/google-product-api)

### Search Google Reverse Image

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_reverse_image')
results = client.search({
  'image_url': 'https://i.imgur.com/5bGzZi7.jpg'
})
pp results[:image_sizes]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_google_reverse_image_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_google_reverse_image_spec.rb)
 * doc: [https://serpapi.com/google-reverse-image](https://serpapi.com/google-reverse-image)

### Search Google Events

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_events')
results = client.search({
  'q': 'coffee'
})
pp results[:events_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_google_events_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_google_events_spec.rb)
 * doc: [https://serpapi.com/google-events-api](https://serpapi.com/google-events-api)

### Search Google Local Services

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_local_services')
results = client.search({
  'q': 'electrician',
  'data_cid': '14414772292044717666'
})
pp results[:local_ads]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_google_local_services_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_google_local_services_spec.rb)
 * doc: [https://serpapi.com/google-local-services-api](https://serpapi.com/google-local-services-api)

### Search Google Maps

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_maps')
results = client.search({
  'q': 'pizza',
  'll': '@40.7455096,-74.0083012,15.1z',
  'type': 'search'
})
pp results[:local_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_google_maps_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_google_maps_spec.rb)
 * doc: [https://serpapi.com/google-maps-api](https://serpapi.com/google-maps-api)

### Search Google Jobs

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_jobs')
results = client.search({
  'q': 'coffee'
})
pp results[:jobs_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_google_jobs_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_google_jobs_spec.rb)
 * doc: [https://serpapi.com/google-jobs-api](https://serpapi.com/google-jobs-api)

### Search Google Play

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_play')
results = client.search({
  'q': 'kite',
  'store': 'apps'
})
pp results[:organic_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_google_play_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_google_play_spec.rb)
 * doc: [https://serpapi.com/google-play-api](https://serpapi.com/google-play-api)

### Search Google Images

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['API_KEY'], engine: 'google_images')
results = client.search({
  "engine": "google",
  "tbm": "isch",
  "q": "coffee"
})
pp results[:images_results]
# ENV['API_KEY'] captures the secret user API available from http://serpapi.com

```

 * source code: [spec/serpapi/example_search_google_images_spec.rb](https://github.com/serpapi/serpapi-ruby/blob/master/spec/serpapi/example_search_google_images_spec.rb)
 * doc: [https://serpapi.com/images-results](https://serpapi.com/images-results)

## Migration quick guide

If you were already using [`google-search-results-ruby` gem](https://github.com/serpapi/google-search-results-ruby), here are the changes.

```ruby
# load library
# old way
require 'google_search_results'
# new way
require 'serpapi'

# define a search
# old way to describe the search
search = GoogleSearch.new(search_params)
# new way
default_parameter = {api_key: "secret_key", engine: "google"}
client = SerpApi::Client.new(default_parameter)
# an instance of the serpapi client is created
# where the default parameters are stored in the client.
#   like api_key, engine
#  then each subsequent API call can be made with additional parameters.

# override an existing parameter
# old way
search.params[:location] = "Portland,Oregon,United States"
# new way
# just provided the search call with the parameters.
results = client.search({location: "Portland,Oregon,United States", q: "Coffe"})

# search format return as raw html
# old way
html_results = search.get_html
# new way
raw_html = client.html(params)
# where params is Hash containing additional key / value

# search format returns a Hash
# old way
hash_results = search.get_hash
# new way
results = client.search(params)
# where params is the search parameters (override the default search parameters in the constructor).

# search as raw JSON format
# old way
json_results = search.get_json
# new way
results = client.search(params)

# The prefix get_ is removed from all other methods.
#  Because it's evident that a method returns something.
# old -> new way
# search.get_search_archive -> client.search_archive
# search.get_account -> client.account
# search.get_location -> client.location
```

Most notable improvements:
 - Removing parameters check on the client side. (most of the bugs)
 - Reduce logic complexity in our implementation. (faster performance)
 - Better documentation.

## Advanced search API usage
### Highly scalable batching

Search API features non-blocking search using the option: `async=true`.
 - Non-blocking - async=true - a single parent process can handle unlimited concurrent searches.
 - Blocking - async=false - many processes must be forked and synchronized to handle concurrent searches. This strategy is I/O usage because each client would hold a network connection.

Search API enables `async` search.
 - Non-blocking (`async=true`) : the development is more complex, but this allows handling many simultaneous connections.
 - Blocking (`async=false`) : it's easy to write the code but more compute-intensive when the parent process needs to hold many connections.

Here is an example of asynchronous searches using Ruby

```ruby
require 'serpapi'
# target MAANG companies
company_list = %w(meta amazon apple netflix google)
client = SerpApi::Client.new({engine: 'google', async: true, api_key: ENV['API_KEY']})
search_queue = Queue.new
company_list.each do |company|
  # store request into a search_queue - no-blocker
  result = client.search({q: company})
  if result[:search_metadata][:status] =~ /Cached|Success/
    puts "#{company}: client done"
    next
  end

  # add results to the client queue
  search_queue.push(result)
end

puts "wait until all searches are cached or success"
while !search_queue.empty?
  result = search_queue.pop
  # extract client id
  search_id = result[:search_metadata][:id]

  # retrieve client from the archive - blocker
  search_archived = client.2(search_id)
  if search_archived[:search_metadata][:status] =~ /Cached|Success/
    puts "#{search_archived[:search_parameters][:q]}: client done"
    next
  end

  # add results to the client queue
  search_queue.push(result)
end

search_queue.close
puts 'done'
```

 * source code: [oobt/demo_async.rb](https://github.com/serpapi/serpapi-ruby/blob/master/oobt/demo_async.rb)

This code shows a simple solution to batch searches asynchronously into a [queue](https://en.wikipedia.org/wiki/Queue_(abstract_data_type)).
Each search takes a few seconds before completion by SerpApi service and the search engine. By the time the first element pops out of the queue. The search result might be already available in the archive. If not, the `search_archive` method blocks until the search results are available.

## Supported Ruby version.
Ruby versions validated by Github Actions:
 - 3.1
 - 2.6
see: [Github Actions.](https://github.com/serpapi/serpapi-ruby/actions/workflows/ci.yml)

## Change logs
 * [2023-02-20] 1.0.0 Full API support

## Developer Guide
### Key goals
 - Brand centric instead of search engine based
   - No hard-coded logic per search engine
 - Simple HTTP client (lightweight, reduced dependency)
   - No magic default values
   - Thread safe
 - Easy extension
 - Defensive code style (raise a custom exception)
 - TDD
 - Best API coding practice per platform
 - KISS principles

### Inspirations
This project source code and coding style was inspired by the most awesome Ruby Gems:
 - [bcrypt](https://github.com/bcrypt-ruby/bcrypt-ruby)
 - [Nokogiri](https://nokogiri.org)
 - [Cloudflare](https://rubygems.org/gems/cloudflare/)
 - [rest-client](https://rubygems.org/gems/rest-client)
 - [stripe](https://rubygems.org/gems/stripe)

### Code quality expectations
 - 0 lint offense: `rake lint`
 - 100% tests passing: `rake test`
 - 100% code coverage: `rake test` (simple-cov)

# Developer Guide
## Design : UML diagram
### Class diagram
```mermaid
classDiagram
  Application *-- serpapi
  serpapi *-- Client
  class Client {
    engine String
    api_key String
    params Hash
    search() Hash
    html() String
    location() String
    search_archive() Hash
    account() Hash
  }
  openuri <.. Client
  json <.. Client
  Ruby <.. openuri
  Ruby <.. json
```
### search() : Sequence diagram
```mermaid
sequenceDiagram
    Client->>SerpApi.com: search() : http request
    SerpApi.com-->>SerpApi.com: query search engine
    SerpApi.com-->>SerpApi.com: parse HTML into JSON
    SerpApi.com-->>Client: JSON string payload
    Client-->>Client: decode JSON into Hash
```
where:
  - The end user implements the application.
  - Client refers to SerpApi:Client.
  - [SerpApi.com](https://serpapi.com) is the backend HTTP / REST service.
  - Engine refers to Google, Baidu, Bing, and more.

The [SerpApi.com](https://serpapi.com) service (backend)
 - executes a scalable search on `engine: "google"` using the search query: `q: "coffee"`.
 - parses the messy HTML responses from Google on the backend.
 - returns a standardized JSON response.
The class SerpApi::Client (client side / ruby):
 - Format the request to SerpApi.com server.
 - Execute HTTP Get request.
 - Parse JSON into Ruby Hash using a standard JSON library.
Et voila!

## Continuous integration
We love "true open source" and "continuous integration", and Test Drive Development (TDD). We are using RSpec to test our infrastructure around the clock using Github Action to achieve the best QoS (Quality Of Service).

The directory spec/ includes specification which serves the dual purposes of examples and functional tests.

Set your secret API key in your shell before running a test.

```bash
export API_KEY="your_secret_key"
```
Install testing dependency
```bash
$ bundle install
# or
$ rake dependency
```

Check code quality using Lint.

```bash
$ rake lint
```

Run regression.

```bash
$ rake test
```

To flush the flow.

```bash
$ rake
```

Open coverage report generated by `rake test`

```sh
open coverage/index.html
```

Open `Rakefile` for more information.

Contributions are welcome. Feel to submit a pull request!

# TODO

- [ ] Release version 1.0.0
