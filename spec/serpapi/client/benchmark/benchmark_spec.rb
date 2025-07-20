require 'spec_helper'
require 'csv'

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

# Create unique filename with client_type, connection_type, and RUBY_VERSION
timestamp = Time.now.strftime('%Y%m%d_%H%M%S_%L')
CSV_FN = "serpapi_ruby_#{RUBY_VERSION.gsub('.', '_')}_#{timestamp}.csv"
# Create the CSV file with headers if it doesn't exist
CSV.open(CSV_FN, 'w') do |csv|
  csv << ['timestamp', 'client_type', 'connection_type', 'requests_count', 'total_time_seconds', 'avg_time_per_request', 'requests_per_second', 'ruby_version']
end

def save(client_type, connection_type, requests_count, runtime)
  # Create CSV with headers and data
  CSV.open(CSV_FN, 'a') do |csv|
    # Add the data row
    avg_time = runtime / requests_count
    rps = requests_count / runtime
    
    csv << [
      Time.now.iso8601,
      client_type,
      connection_type,
      requests_count,
      runtime.round(5),
      avg_time.round(5),
      rps.round(2),
      RUBY_VERSION
    ]
  end

  puts "update benchmark result to: #{File.absolute_path(CSV_FN)}"
end

describe 'benchmark SerpApi client with/without persistent connection' do

  # number of sequential requests
  n = 25

  it 'regular get' do
    puts "start SerpApi regular get benchmark with #{n} requests"
    runtime = Benchmark.measure do
      client = SerpApi::Client.new(persistent: false, engine: 'google', api_key: ENV['SERPAPI_KEY'])
      results = n.times.map { |x| client.search(q: "coffee #{x}") }
      client.close
    end.total
    puts "regular get took #{runtime}s to completed #{n} requests without HTTP persistent connection"
    save('SerpApi', 'non-persistent', n, runtime)
  end

  it 'keep alive' do
    puts "start SerpApi keep alive benchmark with #{n} requests"
    runtime = Benchmark.measure do
      client = SerpApi::Client.new(persistent: true, engine: 'google', api_key: ENV['SERPAPI_KEY'],)
      results = n.times.map { |x| client.search(q: "coffee #{n+x}") }
      client.close 
    end.total
    puts "keep alive took #{runtime}s to completed #{n} requests with HTTP persistent connection"
    save('SerpApi', 'persistent', n, runtime)
  end

end

describe 'benchmark client using http.rb as a baseline' do

  n = 25
  host = "http://api.icndb.com"
  endpoint = "/jokes/random"

  it 'regular get' do
    puts "start HTTP.rb regular get benchmark with #{n} requests"
    runtime = Benchmark.measure do
      n.times do 
        HTTP.get(host + endpoint)
      end
    end.total
    puts "http.rb took #{runtime}s to completed #{n} requests without HTTP persistent connection"
    save('HTTP.rb', 'non-persistent', n, runtime)
  end

  it 'keep alive' do
    puts "start HTTP.rb keep alive benchmark with #{n} requests"
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
    puts "keep alive took #{runtime}s to completed #{n} requests with HTTP persistent connection"
    save('HTTP.rb', 'persistent', n, runtime)
  end
end