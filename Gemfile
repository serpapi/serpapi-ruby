source 'https://rubygems.org'

gemspec

group :development, :production do
  gem 'faraday', '~> 2.13'
end

group :test, :development do
  # HTTP client implementation
  gem 'faraday-httpclient'
  # code coloring for yard
  gem 'redcarpet'
  # documentation generation
  gem 'yard'
  # linter for ruby
  gem 'rubocop'
  # test for ruby
  gem 'rspec'
  # code coverage to monitor rspec tests
  gem 'simplecov'

  platforms :mri do
    gem "byebug"
    gem "pry"
    gem "pry-byebug"
  end
end
