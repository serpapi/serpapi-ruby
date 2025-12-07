# Module includes SerpApi error handling.
# frozen_string_literal: true

module SerpApi
  class SerpApiError < StandardError
    attr_reader :serpapi_error, :search_params, :response_status, :search_id, :decoder

    # All attributes are optional keyword arguments.
    #
    # @param message [String, nil] an optional human message passed to StandardError
    # @param serpapi_error [String, nil] optional error string coming from SerpAPI
    # @param search_params [Hash, nil] optional hash of the search parameters used
    # @param response_status [Integer, nil] optional HTTP or response status code
    # @param search_id [String, nil] optional id returned by the service for the search
    # @param decoder [String, nil] optional decoder/format used (e.g. "json")
    def initialize(message = nil,
                   serpapi_error: nil,
                   search_params: nil,
                   response_status: nil,
                   search_id: nil,
                   decoder: nil)
      super(message)

      @serpapi_error = validate_optional_string(serpapi_error, :serpapi_error)
      @search_params  = freeze_hash(search_params)
      @response_status = validate_optional_integer(response_status, :response_status)
      @search_id = validate_optional_string(search_id, :search_id)
      @decoder = validate_optional_symbol(decoder, :decoder)
    end

    # Return a compact hash representation (omits nil values).
    #
    # @return [Hash]
    def to_h
      {
        message: message,
        serpapi_error: serpapi_error,
        search_params: search_params,
        response_status: response_status,
        search_id: search_id,
        decoder: decoder
      }.compact
    end

    private

    def validate_optional_string(value, name = nil)
      return nil if value.nil?
      unless value.is_a?(String)
        raise TypeError, "expected #{name || 'value'} to be a String, got #{value.class}"
      end

      value.freeze
    end

    def validate_optional_integer(value, name = nil)
      return nil if value.nil?
      return value if value.is_a?(Integer)

      # Accept numeric-like strings (e.g. "200") by converting; fail otherwise.
      begin
        Integer(value)
      rescue ArgumentError, TypeError
        raise TypeError, "expected #{name || 'value'} to be an Integer (or integer-like), got #{value.inspect}"
      end
    end

    def validate_optional_symbol(value, name = nil)
      return nil if value.nil?
      unless value.is_a?(Symbol)
        raise TypeError, "expected #{name || 'value'} to be a Symbol, got #{value.class}"
      end
      value.freeze
    end

    def freeze_hash(value)
      return nil if value.nil?
      unless value.is_a?(Hash)
        raise TypeError, "expected search_params to be a Hash, got #{value.class}"
      end

      # duplicate and freeze to avoid accidental external mutation
      value.dup.freeze
    end
  end
end
