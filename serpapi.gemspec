require_relative 'lib/serpapi/version'

Gem::Specification.new do |s|
  s.name        = 'serpapi'
  s.version     = SerpApi::VERSION
  s.summary     = 'Official Ruby library for SerpApi.com'
  s.description = 'Integrate powerful search functionality into your Ruby application with SerpApi. SerpApi offers official
support for Google, Google Maps, Google Shopping, Baidu, Yandex, Yahoo, eBay, App Stores, and more.
Access a vast range of data, including web search results, local business listings, and product
information.'
  s.authors     = ['Victor Benarbia', 'Julien Khaleghy']
  s.email       = 'victor@serpapi.com'
  s.files       = Dir['{lib}/serpapi.rb'] + Dir['{lib}/serpapi/*.rb']
  s.require_paths = ['lib']
  s.homepage    = 'https://github.com/serpapi/serpapi-ruby'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.7'

  s.metadata = {
    'homepage_uri' => 'https://github.com/serpapi/serpapi-ruby',
    'source_code_uri' => 'https://github.com/serpapi/serpapi-ruby',
    'changelog_uri' => 'https://github.com/serpapi/serpapi-ruby/blob/master/CHANGELOG.md',
    'bug_tracker_uri' => 'https://github.com/serpapi/serpapi-ruby/issues',
    'documentation_uri' => 'https://rubydoc.info/github/serpapi/serpapi-ruby/master',
    'rubygems_mfa_required' => 'true'
  }

  # runtime dependency: HTTP.rb (compatible with both 5.x and 6.x)
  s.add_dependency 'http', '>= 5.2', '< 7.0'

  # development dependency
  s.add_development_dependency 'rake', '~> 13.2.1'
  s.add_development_dependency 'rspec', '~>3.11'
  s.add_development_dependency 'webmock', '~> 3.0'
  s.add_development_dependency 'yard', '~>0.9.28'
  s.add_development_dependency 'rubocop', '~>1.75.7'
  s.add_development_dependency 'csv'
end
