# Client implementation for SerpApi.com
#
module SerpApi
  # Client for SerpApi.com
  # powered by HTTP.rb
  #
  #  it supports:
  #  * async non-block search
  #  * persistent HTTP connection
  #  * many endpoints
  #
  class Client
    # Backend service URL
    BACKEND = 'serpapi.com'.freeze

    # HTTP timeout requests
    attr_reader :timeout,
                # Query parameters
                :params,
                # HTTP persistent
                :persistent,
                # HTTP.rb client
                :socket

    # Constructor
    # The `Serpapi::Client` constructor takes a hash of options as input.
    #
    # **Example:**
    #
    # ```ruby
    # require 'serpapi'
    #
    # client = SerpApi::Client.new(
    #   api_key: "secure API key",
    #   engine: "google",
    #   timeout: 30,
    #   persistent: true
    # )
    #
    # result = client.search(q: "coffee")
    #
    # client.close
    # ```
    #
    # **Parameters:**
    #
    # * `api_key`: [String] User secret API key.
    # * `engine`: [String] Search engine selected.
    # * `persistent`: [Boolean] Keep socket connection open to save on SSL handshake / connection reconnectino (2x
    # faster). [default: true]
    # * `async`: [Boolean] Support non-blocking job submission. [default: false]
    # * `timeout`: [Integer] HTTP get max timeout in seconds [default: 120s == 2m]
    #
    # **Key:**kr
    #
    # The `key` parameter can be either a symbol or a string.
    #
    # **Note:**
    #
    # * All parameters are optional.
    # * The `close` method should be called when the client is no longer needed.
    #
    # @param [Hash] params default for the search
    #
    def initialize(params = {})
      raise SerpApiError, 'params cannot be nil' if params.nil?
      raise SerpApiError, "params must be hash, not: #{params.class}" unless params.instance_of?(Hash)

      # store client HTTP request timeout
      @timeout = params[:timeout] || 120
      @timeout.freeze

      # enable HTTP persistent mode
      @persistent = params[:persistent] || true
      @persistent.freeze

      # delete this client only configuration keys
      %i[timeout persistent].each do |option|
        params.delete(option) if params.key?(option)
      end

      # set default query parameters
      @params = params.clone || {}

      # track ruby library as a client for statistic purpose
      @params[:source] = 'serpapi-ruby:' << SerpApi::VERSION

      # ensure default parameter would not be modified later
      @params.freeze

      # create connection socket
      return unless persistent?

      @socket = HTTP.persistent("https://#{BACKEND}")
    end

    # perform a search using SerpApi.com
    #
    # see: https://serpapi.com/search-api
    #
    #
    # note that the raw response
    #                 from the search engine is converted to JSON by SerpApi.com backend.
    #                 thus, most of the compute power is on the backsdend and not on the client side.
    # @param [Hash] params includes engine, api_key, search fields and more..
    #                this override the default params provided to the constructor.
    # @return [Hash] search results formatted as a Hash.
    def search(params = {})
      get('/search', :json, params)
    end

    # html search
    #
    # @return [String] raw html search results directly from the search engine.
    def html(params = {})
      get('/search', :html, params)
    end

    # Get location using Location API
    #
    # example: spec/serpapi/location_api_spec.rb
    # doc: https://serpapi.com/search-api
    #
    # @param [Hash] params must includes fields: q, limit
    # @return [Array<Hash>] list of matching locations
    def location(params = {})
      get('/locations.json', :json, params)
    end

    # Retrieve search result from the Search Archive API
    #
    # example: spec/serpapi/client/search_archive_api_spec.rb
    # doc: https://serpapi.com/search-archive-api
    #
    # @param [String|Integer] search_id is returned
    # @param [Symbol] format :json or :html [default: json, optional]
    # @return [String|Hash] raw html or JSON / Hash
    def search_archive(search_id, format = :json)
      raise SerpApiError, 'format must be json or html' unless [:json, :html].include?(format)

      get("/searches/#{search_id}.#{format}", format)
    end

    # Get account information using Account API
    #
    # example: spec/serpapi/client/account_api_spec.rb
    # doc: https://serpapi.com/google-jobs-api
    #
    # @param [String] api_key secret key
    # @return [Hash] account information
    def account(api_key = nil)
      params = (api_key.nil? ? {} : { api_key: api_key })
      get('/account', :json, params)
    end

    # @return [String] default search engine
    def engine
      @params[:engine]
    end

    # @return [String] api_key user secret API key as provided to the constructor
    def api_key
      @params[:api_key]
    end

    # close open connection if active
    def close
      @socket.close if @socket
    end

    private

    # @param [Hash] params to merge with default parameters provided to the constructor.
    # @return [Hash] merged query parameters after cleanup
    def query(params)
      raise SerpApiError, "params must be hash, not: #{params.class}" unless params.instance_of?(Hash)

      # merge default params with custom params
      q = @params.merge(params)

      # delete empty key/value
      q.compact
    end

    # @return [Boolean] HTTP session persistent enabled
    def persistent?
      persistent
    end

    # get HTTP query formatted results
    #
    # @param [String] endpoint HTTP service uri
    # @param [Symbol] decoder type :json or :html
    # @param [Hash] params custom search inputs
    # @param [Boolean] symbolize_names if true, convert JSON keys to symbols
    # @return decoded response as JSON / Hash or String
    def get(endpoint, decoder = :json, params = {}, symbolize_names = true)
      # execute get via open socket
      response = if persistent?
                   @socket.get(endpoint, params: query(params))
                 else
                   HTTP.timeout(timeout).get("https://#{BACKEND}#{endpoint}", params: query(params))
                 end

      # decode response using JSON native parser
      case decoder
      when :json
        # read http response
        data = JSON.parse(response.body, symbolize_names: symbolize_names)
        if data.instance_of?(Hash) && data.key?(:error)
          raise SerpApiError, "HTTP request failed with error: #{data[:error]} from url: https://#{BACKEND}#{endpoint}, params: #{params}, decoder: #{decoder}, response status: #{response.status} "
        elsif response.status != 200
          raise SerpApiError, "HTTP request failed with response status: #{response.status} reponse: #{data} on get url: https://#{BACKEND}#{endpoint}, params: #{params}, decoder: #{decoder}"
        end

        # discard response body
        response.flush if persistent?

        data
      else
        response.body
      end
    end
  end
end
