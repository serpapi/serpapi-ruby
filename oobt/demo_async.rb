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
  search_archived = client.search_archive(search_id)
  if search_archived[:search_metadata][:status] =~ /Cached|Success/
    puts "#{search_archived[:search_parameters][:q]}: client done"
    next
  end

  # add results to the client queue
  search_queue.push(result)
end

search_queue.close
puts 'done'