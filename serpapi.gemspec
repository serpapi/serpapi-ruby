require_relative 'lib/serpapi'

Gem::Specification.new do |s|
  s.name        = 'serpapi'
  s.version     = SerpApi::Client::VERSION
  s.summary     = 'Official Ruby wrapper for SerpApi HTTP endpoints'
  s.description = 'Integrate search data into your Ruby application. This library is the official wrapper for SerpApi. SerpApi supports Google, Google Maps, Google Shopping, Baidu, Yandex, Yahoo, eBay, App Stores, and more.'
  s.authors     = ['victor benarbia']
  s.email       = 'victor@serpapi.com'
  s.files       = ['lib/serpapi.rb'] + Dir.glob('lib/serpapi/*.rb')
  s.homepage    = 'https://github.com/serpapi/serpapi-ruby'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 1.9'
  s.add_development_dependency 'rake', '~> 13.0.6'
  s.add_development_dependency 'rspec', '~> 3.11'
  s.add_development_dependency 'yard', '~> 0.9.28'
  s.add_development_dependency 'rubocop', '~> 1.30.1'
end
