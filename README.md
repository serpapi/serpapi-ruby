# SerpApi Ruby Library

[![serpapi-ruby](https://github.com/serpapi/serpapi-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/serpapi/serpapi-ruby/actions/workflows/ci.yml) [![Gem Version](https://badge.fury.io/rb/serpapi.svg)](https://badge.fury.io/rb/serpapi) 

Integrate search data into your AI workflow, RAG / fine-tuning, or Ruby application using this official wrapper for [SerpApi](https://serpapi.com). 

SerpApi supports Google, Google Maps, Google Shopping, Baidu, Yandex, Yahoo, eBay, App Stores, and [more](https://serpapi.com). 

Query a vast range of data at scale, including web search results, flight schedules, stock market data, news headlines, and [more](https://serpapi.com). 

## Features
  * `persistent` → Keep socket connection open to save on SSL handshake / reconnection (2x faster).  [Search at scale](#Search-At-Scale)
  * `async` → Support non-blocking job submission. [Search Asynchronous](#Search-Asynchronous)
  * extensive documentation → easy to follow
  * real world examples → included throughout

## Installation

### RubyGems

```bash
$ gem install serpapi
```

[RubyGems page](https://rubygems.org/gems/serpapi/)

Ruby 2.7 and higher are supported. Other versions, such as Ruby 1.9, Ruby 2.x, and JRuby, are compatible with [legacy SerpApi library](https://github.com/serpapi/google-search-results-ruby), which is still supported. To upgrade to the latest library, check our [migration guide](#Migration-quick-guide).

### Bundler

```ruby
# Gemfile
gem 'serpapi', '~> 1.0', '>= 1.0.3'
```

## Simple Usage

```ruby
require 'serpapi'
client = SerpApi::Client.new(engine: "google", api_key: "<SERPAPI_KEY>")
results = client.search(q: "coffee")
pp results
 ```

This example runs a search for "coffee" on Google. It then returns the results as a regular Ruby Hash.
 See the [playground](https://serpapi.com/playground) to generate your own code.

The SerpApi key can be obtained from [serpapi.com/signup](https://serpapi.com/users/sign_up?plan=free).

Environment variables are a secure, safe, and easy way to manage secrets.
 Set `export SERPAPI_KEY=<secret_serpapi_key>` in your shell.
 Ruby accesses these variables from `ENV['SERPAPI_KEY']`.


## Search API advanced usage with Google search engine

This example dives into all the available parameters for the Google search engine.
The list of parameters depends on the chosen search engine.

```ruby
# load gem
require 'serpapi'

# serpapi client created with default parameters
client = SerpApi::Client.new(
  engine: 'google',
  api_key: ENV['SERPAPI_KEY'],
  # HTTP client configuration
  async: false, # non-blocking HTTP request see: Search Asynchronous (default: false)
  persistent: true, # leave socket connection open for faster response time see: Search at scale (default: true)
  timeout: 5, # HTTP timeout in seconds on the client side only. (default: 120s)
  symbolize_names: true # turn on/off JSON keys to symbols (default: on, more efficient)
)

# search query overview (more fields available depending on search engine)
params = {
  # overview of parameter for Google search engine which is one of many search engine supported.
  # select the search engine (full list: https://serpapi.com/)
  engine: "google",
  # actual search query
  q: "Coffee",
  # then adds search engine specific options.
  # for example: google specific parameters: https://serpapi.com/search-api
  google_domain: "Google Domain",
  # example: Portland,Oregon,United States [ * doc: Location API](#Location-API)
  location: "Location Requested",
  device: "desktop|mobile|tablet",
  hl: "Google UI Language",
  gl: "Google Country",
  safe: "Safe Search Flag",
  start: "Pagination Offset",
  tbm: "nws|isch|shop",
  tbs: "custom to be client criteria",
}

# search results as a symbolized Hash (per performance)
results = client.search(params)

# search results as a raw HTML string
raw_html = client.html(params)
```
 → [SerpApi documentation](https://serpapi.com/search-api).

#### Documentations
This library is well documented, and you can find the following resources:
 * [Full documentation on SerpApi.com](https://serpapi.com)
 * [Library Github page](https://github.com/serpapi/serpapi-ruby)
 * [Library GEM page](https://rubygems.org/gems/serpapi/)
 * [Library API documentation](https://rubydoc.info/github/serpapi/serpapi-ruby/master)
 * [API health status](https://serpapi.com/status)

## Advanced search API usage
### Search Asynchronous

Search API features non-blocking search using the option: `async=true`.
 - Non-blocking - async=true - a single parent process can handle unlimited concurrent searches.
 - Blocking - async=false - many processes must be forked and synchronized to handle concurrent searches. This strategy is I/O usage because each client would hold a network connection.

Search API enables `async` search.
 - Non-blocking (`async=true`) : the development is more complex, but this allows handling many simultaneous connections.
 - Blocking (`async=false`) : it is easy to write the code but more compute-intensive when the parent process needs to hold many connections.

Here is an example of asynchronous searches using Ruby 
```ruby
require 'serpapi'

company_list = %w[meta amazon apple netflix google]
client = SerpApi::Client.new(engine: 'google', async: true, persistent: true, api_key: ENV['SERPAPI_KEY'])
schedule_search = Queue.new
result = nil
company_list.each do |company|
  result = client.search(q: company)
  puts "#{company}: search results found in cache for: #{company}" if result[:search_metadata][:status] =~ /Cached/

  schedule_search.push(result[:search_metadata][:id])
end

puts "Last search submited at: #{result[:search_metadata][:created_at]}"

puts 'wait 10s for all requests to be completed '
sleep(10)

puts 'wait until all searches are cached or success'
until schedule_search.empty?
  search_id = schedule_search.pop

  search_archived = client.search_archive(search_id)

  company = search_archived[:search_parameters][:q]

  if search_archived[:search_metadata][:status] =~ /Cached|Success/
    puts "#{search_archived[:search_parameters][:q]}: search results found in archive for: #{company}"
    next
  end

  schedule_search.push(search_id)
end

schedule_search.close
puts 'done'
```

 * source code: [demo/demo_async.rb](https://github.com/serpapi/serpapi-ruby/blob/master/demo/demo_async.rb)

This code shows a simple solution to batch searches asynchronously into a [queue](https://en.wikipedia.org/wiki/Queue_(abstract_data_type)). Each search may take up to few seconds to complete. By the time the first element pops out of the queue, the search results might already be available in the archive. If not, the `search_archive` method blocks until the search results are available.

### Search at scale
The provided code snippet is a Ruby spec test case that demonstrates the use of thread pools to execute multiple HTTP requests concurrently.

```ruby
require 'serpapi'
require 'connection_pool'

# create a thread pool of 4 threads with a persistent connection to serpapi.com
# timeout is the connection checkout wait, so it must outlast an in-flight search
pool = ConnectionPool.new(size: n, timeout: 60) do
  SerpApi::Client.new(engine: 'google', api_key: ENV['SERPAPI_KEY'], timeout: 30, persistent: true)
end

# run user thread to search for your favorites coffee type
threads = %w(latte espresso cappuccino americano mocha macchiato frappuccino cold_brew).map do |query|
  Thread.new do
    pool.with { |socket| socket.search(q: query).to_s }
  end
end
responses = threads.map(&:value)
```

The code aims to demonstrate how thread pools can be used to 
improve performance by executing multiple tasks concurrently. In 
this case, it makes multiple HTTP requests to an API endpoint using 
a thread pool of persistent connections.

Note: `gem install connection_pool` to run this example.

**Benefits:**

* Improved performance by avoiding the overhead of creating and destroying connections for each request.
* Efficient use of resources by sharing connections among multiple threads.
* Concurrency and parallelism, allowing multiple requests to be processed simultaneously.

### Real world search without persistency

```ruby
require 'serpapi'
require 'pp'

client = SerpApi::Client.new(api_key: ENV['SERPAPI_KEY'])
params = {
  q: 'coffee'
}
results = client.search(params)
unless results[:organic_results]
  puts 'no organic results found'
  exit 1
end
pp results[:organic_results]
puts 'done'
exit 0
```

 * source code: [demo/demo.rb](https://github.com/serpapi/serpapi-ruby/blob/master/demo/demo.rb)

## APIs supported
### Location API

```ruby
require 'serpapi'
client = SerpApi::Client.new
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

First, you need to run a search and save the search ID.

```ruby
require 'serpapi'
client = SerpApi::Client.new(engine: 'google', api_key: ENV['SERPAPI_KEY'])
results = client.search(q: "Coffee", location: "Portland")
search_id = results[:search_metadata][:id]
```

Now we can retrieve the previous search results from the archive using the search ID (free of charge).

```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['SERPAPI_KEY'])
results = client.search_archive(search_id)
pp results
```

This code prints the search results from the archive. :)

### Account API
```ruby
require 'serpapi'
client = SerpApi::Client.new(api_key: ENV['SERPAPI_KEY'])
pp client.account
```

It prints your account information as:
```ruby
{
  account_id: "1234567890",
  api_key: "your_secret_key",
  account_email: "email@company.com",
  account_status: "Active",
  plan_id: "free",
  plan_name: "Free Plan",
  plan_monthly_price: 0.0,
  searches_per_month: 250,
  plan_searches_left: 250,
  extra_credits: 0,
  total_searches_left: 250,
  this_month_usage: 0,
  this_hour_searches: 0,
  last_hour_searches: 0,
  account_rate_limit_per_hour: 250
}
 ```

## Examples

Here are some examples for some of our most popular APIs. You can find the full list of supported engines and parameters in our [documentation](https://serpapi.com/search-engine-apis).

### Google Shopping

Scrape Google Shopping results with product names, prices, ratings, and merchant information.

```ruby
require 'serpapi'

client = SerpApi::Client.new(engine: 'google_shopping', api_key: ENV['SERPAPI_KEY'])
results = client.search(q: 'Macbook M4')
pp results[:shopping_results]
```

[See documentation](https://serpapi.com/google-shopping-api)

**Google Shopping Light**

A [light variant](https://serpapi.com/google-shopping-light-api) engine called `google_shopping_light` is also available for faster, lower-cost shopping searches.

### Google Images

Scrape Google Images search results, including image URLs, thumbnails, titles, and source pages.

```ruby
require 'serpapi'

client = SerpApi::Client.new(engine: 'google_images', api_key: ENV['SERPAPI_KEY'])
results = client.search(q: 'coffee')
pp results[:images_results]
```

[See documentation](https://serpapi.com/images-results)

**Google Images Light**

A [light variant](https://serpapi.com/google-images-light-api) engine called `google_images_light` is also available for faster, lower-cost image searches.

### Google Trends

Track search interest over time and compare the popularity of search terms.

```ruby
require 'serpapi'

client = SerpApi::Client.new(engine: 'google_trends', api_key: ENV['SERPAPI_KEY'])
results = client.search(q: 'coffee', data_type: 'TIMESERIES')
pp results[:interest_over_time]
```

[See documentation](https://serpapi.com/google-trends-api)

### Google Flights

Search flight routes, schedules, prices, and booking options.

> **Note:** The `google_flights` engine does not use `q`. Specify route and date parameters such as `departure_id`, `arrival_id`, `outbound_date`, and `return_date`.

```ruby
require 'date'
require 'serpapi'

outbound_date = (Date.today + 30).iso8601
return_date = (Date.today + 37).iso8601
client = SerpApi::Client.new(engine: 'google_flights', api_key: ENV['SERPAPI_KEY'])
results = client.search(
  departure_id: 'LAX',
  arrival_id: 'AUS',
  outbound_date: outbound_date,
  return_date: return_date
)
flights = results[:best_flights] || results[:other_flights]
pp flights
```

[See documentation](https://serpapi.com/google-flights-api)

### Google AI Mode API

The Google AI Mode API returns AI-generated answers with structured text blocks, references, images, products, and more.

```ruby
require 'serpapi'

client = SerpApi::Client.new(engine: 'google_ai_mode', api_key: ENV['SERPAPI_KEY'])
results = client.search(q: 'best coffee maker')
pp results[:reconstructed_markdown]
```

[See documentation](https://serpapi.com/google-ai-mode-api)

### Bing Search

Scrape Bing web search results, including organic results, ads, related searches, and more.

```ruby
require 'serpapi'

client = SerpApi::Client.new(engine: 'bing', api_key: ENV['SERPAPI_KEY'])
results = client.search(q: 'coffee')
pp results[:organic_results]
```

[See documentation](https://serpapi.com/bing-search-api)

### DuckDuckGo Search

Scrape DuckDuckGo search results, including organic results, ads, knowledge graphs, and related searches.

```ruby
require 'serpapi'

client = SerpApi::Client.new(engine: 'duckduckgo', api_key: ENV['SERPAPI_KEY'])
results = client.search(q: 'coffee')
pp results[:organic_results]
```

[See documentation](https://serpapi.com/duckduckgo-search-api)

### Baidu Search

Scrape Baidu search results, including organic results, answer boxes, and related searches.

```ruby
require 'serpapi'

client = SerpApi::Client.new(engine: 'baidu', api_key: ENV['SERPAPI_KEY'])
results = client.search(q: 'coffee')
pp results[:organic_results]
```

[See documentation](https://serpapi.com/baidu-search-api)

### Amazon Search

Scrape Amazon product search results, including product names, prices, ratings, reviews, and availability.

> **Note:** The `amazon` engine uses the `k` parameter for a keyword search, not `q`.

```ruby
require 'serpapi'

client = SerpApi::Client.new(engine: 'amazon', api_key: ENV['SERPAPI_KEY'])
results = client.search(k: 'coffee')
pp results[:organic_results]
```

[See documentation](https://serpapi.com/amazon-search-api)

## Migration quick guide

If you were already using [google-search-results-ruby gem](https://github.com/serpapi/google-search-results-ruby), here are the changes.

```
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
results = client.search(location: "Portland,Oregon,United States", q: "Coffee")

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
search.get_search_archive -> client.search_archive
search.get_account -> client.account
search.get_location -> client.location
```

Most notable improvements:
 - Removing parameters check on the client side. (most of the bugs)
 - Reduce logic complexity in our implementation. (faster performance)
 - Better documentation.

## Supported Ruby versions

Ruby 2.7 and higher is supported.

## Contributing

Contributions are welcome. Make sure to read our [contributing guide](./CONTRIBUTING.md).
