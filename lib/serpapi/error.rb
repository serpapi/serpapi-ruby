# Standard SerpApiException for anything related to the client
#
module SerpApi

  class SerpApiException < StandardError

    def initialize(message)
      super(message)
    end

  end

end