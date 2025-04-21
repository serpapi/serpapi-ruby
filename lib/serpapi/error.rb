# Module includes SerpApi exception
#
module SerpApi
  #  SerpApiException wraps anything related to the SerpApi client errors.
  #
  module Errors
    class SerpApiException < StandardError
    end
  end
end
