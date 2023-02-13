# code coverage
require 'simplecov'
SimpleCov.start 'rails'

# load libary
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'serpapi'
