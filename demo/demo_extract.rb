# This script demonstrates the SerpApi Extract API (engine: extract).
#
# The Extract API returns the main content of any public web page as Markdown,
# along with page information, meta tags, structured data and inline links.
# The same endpoint exposes three modes:
# - `scrape` (default): extract a single page
# - `map`: list the website's URLs from page links and sitemaps
# - `crawl`: follow links on the same website up to `max_pages` / `max_depth`
#   and extract every visited page (one search credit per extracted page)
#
# To extract a page found in the results (e.g. in inline_links), pass its URL
# to `extract` again.
#
# Ensure that the `SERPAPI_KEY` environment variable is set before running this script.
#
# doc: https://serpapi.com/extract-api

raise 'SERPAPI_KEY environment variable must be set' if ENV['SERPAPI_KEY'].nil?

require 'pp'
require 'serpapi'

# client initialization, engine is set per call by the extract method
client = SerpApi::Client.new(api_key: ENV['SERPAPI_KEY'])

# 1. scrape a single page (default mode)
puts '--- scrape: https://example.com/'
results = client.extract(url: 'https://example.com/')
pp results[:page_information]
puts results[:markdown]

# 2. get only the page's Markdown as a String
puts '--- markdown output: https://example.com/'
puts client.extract(url: 'https://example.com/', output: 'md')

# 3. map: list the URLs of a website
puts '--- map: https://books.toscrape.com/'
results = client.extract(url: 'https://books.toscrape.com/', mode: 'map')
urls = results[:urls] || []
puts "discovered #{urls.size} urls"
pp urls.first(5)

# 4. crawl: extract every visited page up to max_pages / max_depth
puts '--- crawl: https://books.toscrape.com/'
results = client.extract(url: 'https://books.toscrape.com/', mode: 'crawl', max_pages: 3, max_depth: 1)
pages = results[:pages] || []
pages.each do |page|
  puts "#{page.dig(:page_information, :title)} - #{page[:url]}"
end

# 5. follow a link: extract the first inline link of https://example.com/
puts '--- follow: the first inline link of https://example.com/'
results = client.extract(url: 'https://example.com/')
link = results[:inline_links]&.first&.dig(:link)
if link
  linked_page = client.extract(url: link)
  pp linked_page[:page_information]
else
  puts 'no inline link found to follow'
end

# close the underlying persistent connection
client.close
puts 'done'
exit 0
