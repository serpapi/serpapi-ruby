# Module includes SerpApi exception
module SerpApi  
  # SerpApiException wraps any errors related to the SerpApi client.
  class SerpApiError < StandardError
    # List the specific types of errors handled by the Error class.
    #  - Missing API key
    #  - Credit limit
    #  - Incorrect query
    #  - more ...
  end
end
