require 'spec_helper'

describe 'account API' do
  it 'fetch user account information' do
    client = SerpApi::Client.new(api_key: ENV['SERPAPI_KEY'])

    # mock response if no SERPAPI_KEY specified
    if ENV['SERPAPI_KEY'].nil?
      allow(search).to receive(:get_results) {
        '{
          "account_id": "5ac54d6adefb2f1dba1663f5",
          "api_key": "SECRET_SERPAPI_KEY",
          "account_email": "demo@serpapi.com",
          "plan_id": "bigdata",
          "plan_name": "Big Data Plan",
          "searches_per_month": 30000,
          "this_month_usage": 24042,
          "last_hour_searches": 42
        }'
      }
    end

    account_info = client.account
    expect(account_info.keys.size).to be > 5
    expect(account_info[:account_id]).not_to be_empty
    expect(account_info[:api_key]).not_to be_empty
    expect(account_info[:account_email]).not_to be_empty

    puts "search left: #{account_info[:plan_searches_left]}"
  end
end
