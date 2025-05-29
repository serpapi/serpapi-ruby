require 'spec_helper'

# This benchmark demonstrates that persistent connections are 2x quicker than regular HTTP connection.
#
# ```
# serpapi client took 0.07852 to completed 10 requests without HTTP persistent connection
# serpapi client took 0.04787s to completed 10 requests with HTTP persistent connection
# ```
#
# Vanilal http.rb querying another server
# ```
# http.rb took 0.02246s to completed 10 requests with HTTP persistent connection
# http.rb took 0.04100s to completed 10 requests without HTTP persistent connection
# ````
# For an example of thread pool where the socket connection can be shared see: thread_pool_spec.rb 

describe 'benchmark SerpApi client with/without persistent connection' do

  # number of sequential requests
  n = 10

  it 'regular get' do
    runtime = Benchmark.measure do
      client = SerpApi::Client.new(persistent: false, engine: 'google', api_key: ENV['API_KEY'])
      results = n.times.map { |x| client.search(q: "coffee #{x}") }
      client.close
    end.total
    puts "serpapi client took #{runtime}s to completed #{n} requests without HTTP persistent connection"
  end

  it 'keep alive' do
    runtime = Benchmark.measure do
      client = SerpApi::Client.new(persistent: true, engine: 'google', api_key: ENV['API_KEY'],)
      results = n.times.map { |x| client.search(q: "coffee #{n+x}") }
      client.close 
    end.total
    puts "serpapi client took #{runtime}s to completed #{n} requests with HTTP persistent connection"
  end

end

describe 'benchmark client using http.rb as a baseline' do

  n = 10
  host = "http://api.icndb.com"
  endpoint = "/jokes/random"

  it 'regular get' do
    runtime = Benchmark.measure do
      n.times do 
        HTTP.get(host + endpoint)
      end
    end.total
    puts "http.rb took #{runtime}s to completed #{n} requests without HTTP persistent connection"
  end

  it 'keep alive' do
    runtime = Benchmark.measure do
      begin
        # create HTTP client with persistent connection to api.icndb.com:
        http = HTTP.persistent host

        # issue multiple requests using same connection:
        jokes = n.times.map { http.get(endpoint).to_s }
      ensure
        # close underlying connection when you don't need it anymore
        http.close if http
      end
    end.total
    puts "http.rb took #{runtime}s to completed #{n} requests with HTTP persistent connection"
    #expect(runtime).to be_within(0.1).of(0.02) # Adjust the tolerance as needed
  end
end