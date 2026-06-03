# Offline test helper.
#
# Unlike spec/spec_helper.rb, these specs need NO `SERPAPI_KEY` and make NO
# network calls: every HTTP request is stubbed with WebMock. This lets the core
# client logic be tested for free, on every Ruby version, in any fork or CI.
# frozen_string_literal: true

require 'webmock/rspec'

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
require 'serpapi'

# Base URL of the SerpApi backend, used to build WebMock stubs.
SERPAPI_BACKEND = 'https://serpapi.com'

# Hard fail if any spec accidentally reaches the real network.
WebMock.disable_net_connect!(allow_localhost: false)
