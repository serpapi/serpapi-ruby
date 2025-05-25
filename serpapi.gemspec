
if RUBY_VERSION < '2.1.0'
  load File.join(File.dirname(__FILE__), 'lib/serpapi/version')
 else
  require_relative 'lib/serpapi/version'
 end

Gem::Specification.new do |s|
  s.name        = 'serpapi'
if RUBY_VERSION < '2.1.0'
  s.version     = "1.0.0"
else
  s.version     = SerpApi::VERSION
end
  s.summary     = 'Official Ruby wrapper for SerpApi HTTP endpoints'
  s.description = 'Integrate search data into your Ruby application. This library is the official wrapper for SerpApi. SerpApi supports Google, Google Maps, Google Shopping, Baidu, Yandex, Yahoo, eBay, App Stores, and more.'
  s.authors     = ['victor benarbia']
  s.email       = 'victor@serpapi.com'
  s.files       = Dir['{lib}/serpapi.rb'] + Dir['{lib}/serpapi/*.rb']
  s.require_paths = ['lib']
  s.homepage    = 'https://github.com/serpapi/serpapi-ruby'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 3.1'

  # faraday
  s.add_dependency 'faraday', '~> 2.13'

  # development dependency
  s.add_development_dependency 'rake', '~> 13.2.1'
  s.add_development_dependency 'rspec', '~>3.11'
  s.add_development_dependency 'yard', '~>0.9.28'
  s.add_development_dependency 'rubocop', '~>1.75.7'

end
