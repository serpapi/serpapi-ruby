# This script demonstrates the SerpApi Extract API (engine: extract).
#
# The Extract API turns any public web page into a fully structured JSON document.
# The same endpoint exposes three modes:
# - `scrape` (default): extract a single page into structured JSON
#   (page information, meta tags, structured data, headings, inline links, text content, ...)
# - `map`: fast same-origin URL discovery via page links, robots.txt and sitemap.xml
# - `crawl`: crawl pages on the same website up to `max_pages` / `max_depth`
#   and return a fully parsed JSON document for every visited page.
#
# Items carrying a navigable page URL (inline_links, breadcrumbs, price_offers,
# urls, pages, ...) are enriched with a `serpapi_extract_link` so extractions
# can be chained with `extract_link` without rebuilding the query.
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
pp results[:text_content]

# 2. map: discover same-origin URLs of a website
puts '--- map: https://books.toscrape.com/'
results = client.extract(url: 'https://books.toscrape.com/', mode: 'map', max_pages: 10)
urls = results[:urls] || []
puts "discovered #{urls.size} urls"
pp urls.first(5)

# 3. crawl: parse every visited page up to max_pages / max_depth
puts '--- crawl: https://books.toscrape.com/'
results = client.extract(url: 'https://books.toscrape.com/', mode: 'crawl', max_pages: 3, max_depth: 1)
pages = results[:pages] || []
pages.each do |page|
  puts "#{page.dig(:page_information, :title)} - #{page.dig(:page_information, :url)}"
end

# 4. chain extractions using serpapi_extract_link
puts '--- chain: follow the first inline link of https://example.com/'
results = client.extract(url: 'https://example.com/')
link = results[:inline_links]&.first&.dig(:serpapi_extract_link)
if link
  linked_page = client.extract_link(link)
  pp linked_page[:page_information]
else
  puts 'no inline link found to follow'
end

# close the underlying persistent connection
client.close
puts 'done'
exit 0
