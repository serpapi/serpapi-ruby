source 'https://rubygems.org'

gemspec

group :development, :production do
  gem 'http', '~> 0.13.3'
end

group :test, :development do
  # code coloring for yard
  gem 'redcarpet'
  # documentation generation
  gem 'yard', '~>0.9.28'
  # linter for ruby
  gem 'rubocop', '~>1.75.7'
  # test for ruby
  gem 'rspec', '~>3.11'
  # code coverage to monitor rspec tests
  gem 'simplecov'

  # Thread pool example file: thread_pool_spec.rb
  # https://github.com/mperham/connection_pool/tree/main
  gem 'connection_pool'

  # Benchmark is no longer included in Ruby 3.5
  gem 'benchmark'
  
end
