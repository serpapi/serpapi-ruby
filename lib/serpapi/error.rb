# Module includes SerpApi exception
#
module SerpApi
  # Errors module contains all the exceptions used in the SerpApi client.
  #
  module Errors
    #  SerpApiException wraps anything related to the SerpApi client errors.
    #
    class SerpApiException < StandardError
    end
  end
end
