
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
  s.required_ruby_version = '>= 1.9'

  # faraday
  s.add_dependency 'faraday', '~> 2.13'

#  s.add_development_dependency 'rake'
#  s.add_development_dependency 'rspec'
#  s.add_development_dependency 'yard'
#  s.add_development_dependency 'rubocop'

  # break
  # # add Ruby version specific dependencies
  if  RUBY_VERSION > '2.2.0'
     # Ruby 2.3+
     s.add_development_dependency 'rake', '~> 13.0.6'
     s.add_development_dependency 'rspec', '~> 3.11'
     s.add_development_dependency 'yard', '~> 0.9.28'
     s.add_development_dependency 'rubocop', '~> 1.30.1'
  else
   #  if RUBY_VERSION < '2.0.0'
     # Ruby 1.9
     s.add_development_dependency 'rake', '~> 12.2'
     s.add_development_dependency 'rspec', '~> 2.01'
  end
end
