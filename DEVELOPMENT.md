# Developer Guide

## Key goals

 - Brand centric instead of search engine based
   - No hard-coded logic per search engine
 - Simple HTTP client (lightweight, reduced dependency)
   - No magic default values
   - Thread safe
 - Easy extension
 - Defensive code style (raise a custom exception)
 - TDD - Test driven development
 - Best API coding practice per platform
 - KiSS principles

## Inspirations

This project source code and coding style was inspired by the most awesome Ruby Gems:
 - [bcrypt](https://github.com/bcrypt-ruby/bcrypt-ruby)
 - [Nokogiri](https://nokogiri.org)
 - [Cloudfare](https://rubygems.org/gems/cloudflare/versions/2.1.0)
 - [rest-client](https://rubygems.org/gems/rest-client)
 - [stripe](https://rubygems.org/gems/stripe)
 
## Code quality expectations

 - 0 lint offense: `rake lint`
 - 100% tests passing: `rake test`
 - 100% code coverage: `rake coverage` (simple-cov)
