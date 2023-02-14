require_relative 'lib/serpapi'

Gem::Specification.new do |s|
  s.name        = 'serpapi'
  s.version     = SerpApi::Client::VERSION
  s.summary     = 'Scrape and search localized results from Google, Bing, Baidu, Yahoo, Yandex, Ebay, Homedepot, youtube, and more at scale using serpapi.com'
  s.description = 'This library integrates with SerpApi.com which allows to perform search on all major search engines and returns a formatted Hash or raw HTML'
  s.authors     = ['victor benarbia']
  s.email       = 'victor@serpapi.com'
  s.files       = ['lib/serpapi.rb'] + Dir.glob('lib/serpapi/*.rb')
  s.homepage    = 'https://github.com/serpapi/serpapi-ruby'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.5.3'
  s.add_development_dependency 'rake', '~> 13.0.6'
  s.add_development_dependency 'rspec', '~> 3.11'
  s.add_development_dependency 'yard', '~> 0.9.28'
  s.add_development_dependency 'rubocop', '~> 1.30.1'
end
