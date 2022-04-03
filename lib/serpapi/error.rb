# Module includes all exception
#
module SerpApi
  # Standard SerpApiException for anything related to the client
  #
  class SerpApiException < StandardError
    def initialize(message)
      super(message)
    end
  end
end
