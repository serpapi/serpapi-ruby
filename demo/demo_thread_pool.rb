
# The provided code snippet is a Ruby spec test case that 
# demonstrates the use of thread pools to execute multiple HTTP 
# requests concurrently.
#
# **Key Points:**
#
# * The `connection_pool` gem is used to create a thread pool of 
# `HTTP` connections.
# * The `Thread` class is used to spawn multiple threads, each of 
# which makes a GET request to the specified endpoint.
# * The `pool.with` method is used to acquire a connection from the 
# thread pool and use it to make the HTTP request.
# * The `to_s` method converts the HTTP response to a string.
# * The `total` method from the `Benchmark` class is used to measure 
# the total execution time of the code block.

# **Purpose:**

# The code aims to demonstrate how thread pools can be used to 
# improve performance by executing multiple tasks concurrently. In 
# this case, it makes multiple HTTP requests to an API endpoint using 
# a thread pool of connections.
#
# **Benefits:**
#
# * Improved performance by avoiding the overhead of creating and 
# destroying connections for each request.
# * Efficient use of resources by sharing connections among multiple 
# threads.
# * Concurrency and parallelism, allowing multiple requests to be 
# processed simultaneously.
#
# **Usage:**
#
# The code snippet can be used as a reference to implement thread 
# pools in Ruby applications. It provides an example of how to use 
# the `connection_pool` gem to create a thread pool of connections 
# and make concurrent HTTP requests.
#
# **Additional Notes:**
#
# * The number of threads created should be set to an appropriate 
# value based on the available resources and the expected request 
# load.
# * The `timeout` option in the `ConnectionPool` constructor 
# specifies the maximum time a thread should wait to acquire a 
# connection from the pool.
# * The `HTTP.persistent` method is used to create persistent 
# connections, which can improve performance by reusing connections 
# between requests.
# * The `benchmark` gem is used to measure the execution time of the 
# code block.
# reference: https://github.com/httprb/http/wiki/Thread-Safety

require 'serpapi'
require 'benchmark'
require 'connection_pool'

# number of thread == number of HTTP persistent connection
n = 4
runtime = Benchmark.measure do 
  # create a thread pool of 4 threads with a persistent connection to serpapi.com
  pool = ConnectionPool.new(size: n, timeout: 5) do
      SerpApi::Client.new(engine: 'google', api_key: ENV['API_KEY'], timeout: 30, persistent: true)
  end

  # run user thread to search for your favorites coffee type
  threads = %w(latte espresso cappuccino americano mocha macchiato frappuccino cold_brew).map do |query|
    Thread.new do
      pool.with { |socket| socket.search({q: query }).to_s }
    end
  end
  responses = threads.map(&:value)
end.total
puts "total runtime: #{runtime}s for #{n} threads == #{n} HTTP connections"
