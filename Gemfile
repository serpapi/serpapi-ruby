source 'https://rubygems.org'

gemspec

group :development, :production do
  gem 'http', '~> 5.2'
end

group :test, :development do
  # code coloring for yard
  gem 'redcarpet'
  # documentation generation
  gem 'yard', '~>0.9.28'
  # linter for ruby
  gem 'rubocop', '~>1.75.7'
  gem 'rubocop-rake', require: false # for rake tasks linting
  # test for ruby
  gem 'rspec', '~>3.11'
  # code coverage to monitor rspec tests
  gem 'simplecov'
  # save CSV files
  gem 'csv'

  # Thread pool example file: thread_pool_spec.rb
  # https://github.com/mperham/connection_pool/tree/main
  gem 'connection_pool'

  # Benchmark is no longer included in Ruby 3.5
  gem 'benchmark'

end
