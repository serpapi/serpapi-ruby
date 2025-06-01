# The code snippet aims to improve the efficiency of searching using the SerpApi client using `async` mode.
# The request are non-blocking which allows batching a large amount of query, and wait before fetching the result back.
#
# **Process:**
# 1. **Request Queue:** The company list is iterated over, and each company is queried using the SerpApi client. Requests
# are stored in a queue to avoid blocking the main thread.
#
# 2. **Client Retrieval:** After each request, the code checks the status of the search result. If it's cached or
# successful, the company name is printed, and the request is skipped. Otherwise, the result is added to the queue for
# further processing.
#
# 3. **Queue Processing:** The queue is processed until it's empty. In each iteration, the last result is retrieved and
# its client ID is extracted.
#
# 4. **Archived Client Retrieval:** Using the client ID, the code retrieves the archived client and checks its status. If
# it's cached or successful, the company name is printed, and the client is skipped. Otherwise, the result is added back
# to the queue for further processing.
#
# 5. **Completion:** The queue is closed, and a message is printed indicating that the process is complete.
#
# * **Asynchronous Requests:** The `async: true` option ensures that search requests are processed in parallel, improving
# efficiency.
# * **Queue Management:** The queue allows requests to be processed asynchronously without blocking the main thread.
# * **Status Checking:** The code checks the status of each search result before processing it, avoiding unnecessary work.
# * **Queue Processing:** The queue ensures that all requests are processed in the order they were submitted.

# **Overall, the code snippet demonstrates a well-structured approach to improve the efficiency of searching for company
# information using SerpApi.**

# load serpapi library
require 'serpapi'

# target MAANG companies
company_list = %w[meta amazon apple netflix google]
client = SerpApi::Client.new(engine: 'google', async: true, persistent: true, api_key: ENV.fetch('SERPAPI_KEY', nil))
schedule_search = Queue.new
result = nil
company_list.each do |company|
  # store request into a schedule_search - no-blocker
  result = client.search({ q: company })
  puts "#{company}: search results found in cache for: #{company}" if result[:search_metadata][:status] =~ /Cached/

  # add results to the client queue
  schedule_search.push(result[:search_metadata][:id])
end

puts "Last search submited at: #{result[:search_metadata][:created_at]}"

# wait for all requests to be completed
puts 'wait 10s for all requests to be completed '
# wait for 10 seconds to allow all requests to be processed
sleep(10)

puts 'wait until all searches are cached or success'
until schedule_search.empty?
  # extract client id
  search_id = schedule_search.pop

  # retrieve client from the archive - blocker
  search_archived = client.search_archive(search_id)

  # read original company name from the search parameters
  company = search_archived[:search_parameters][:q]

  # check if the search is cached or successful
  if search_archived[:search_metadata][:status] =~ /Cached|Success/
    puts "#{search_archived[:search_parameters][:q]}: search results found in archive for: #{company}"
    next
  end

  # add results back to the client queue
  #  if the search is still in progress
  schedule_search.push(result)
end

# destroy the queue
schedule_search.close
puts 'done'
