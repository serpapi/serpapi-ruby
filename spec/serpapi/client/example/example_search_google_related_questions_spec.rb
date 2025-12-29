require 'spec_helper'

describe 'example: google_related_questions search' do
  it 'prints related_questions' do
    # Confirm that the environment variable for SERPAPI_KEY has been set properly.
    #  Your SerpApi key can be obtained at this URL http://serpapi.com
    api_key = ENV['SERPAPI_KEY']
    skip('SERPAPI_KEY not set. Please set your SerpApi API key.') if api_key.nil?

    # initialize the serp api client
    client = SerpApi::Client.new(engine: 'google_related_questions', api_key: api_key)
    # run a search using serpapi service
    results = client.search({
      next_page_token: 'eyJvbnMiOiIxMDA0MSIsImZjIjoiRW9vQkNreEJTa2M1U210T1JsQjZhMjAyTVRCMVVsRmhlV05HVnpSdUxTMTRWemhVUm5OVk4yaGxjRXRCWlRKR1RUbHlRWGswU2sxWWVXSTVYemhIWkhWTFNscExNRUpPV25WNWFtcFFUa3d3RWhaT1RIWmFXbk54WDBSTVV6RjNUalJRYnpkcVdFOUJHaUpCUmxoeVJXTnZZMHBFWmxacU5GQnljR3h0Um5KV1lsOVdOVmh1WkcxWFZGRjMiLCJmY3YiOiIzIiwiZWkiOiJOTHZaWnNxX0RMUzF3TjRQbzdqWE9BIiwicWMiOiJDZ1pqYjJabVpXVVFBSDA1VEQ4XyIsInF1ZXN0aW9uIjoiSXMgY29mZmVlIGdvb2Qgb3IgYmFkIGZvciBoZWFsdGg/IiwibGsiOiJHaUJwY3lCamIyWm1aV1VnWjI5dlpDQnZjaUJpWVdRZ1ptOXlJR2hsWVd4MGFBIiwiYnMiOiJjLVB5NGxMMExGWkl6azlMUzAxVlNNX1BUMUhJTDFKSVNreFJTQVBTR2FtSk9TVVo5aEtiZUl5VXBCUXlDYWpqY3VHU0M4LW9SRkpYbkE5UkNsSlRtVjlxTDdGWnpraGVTclljbnlJdVZ5NzU4SXpFRW9YRW9sUUZRd09GcE5TODFMVE1rbUtGX0RTb0Ruc0pFeU1GS2JseXZJcTQ0cmgwd01hazVLY0NoZk5TRlpKTEN4RFNRR0dGa255UWZVQmY1S2RVMmtzc3JqWFNsdElzaDJzeHhLOUJnQkVBIiwiaWQiOiJmY19OTHZaWnNxX0RMUzF3TjRQbzdqWE9BXzQifQ=='
    })
    expect(results[:related_questions]).not_to be_nil, "No related questions found! keys available: #{results.keys}"

    # print the output of the response in formatted JSON
    # pp results[:related_questions]
    # doc: http://serpapi.com/google-related-questions-api
  end
end
