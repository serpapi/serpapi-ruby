# Client implementation for SerpApi.com
#
module SerpApi
  # Client for SerpApi.com
  # powered by HTTP.rb
  #
  #  features:
  #  * async non-block search
  #  * persistent HTTP connection
  #  * search API
  #  * location API
  #  * account API
  #  * search archive API
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
    # * `symbolize_names`: [Boolean] Convert JSON keys to symbols. [default: true]
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
      @persistent = true
      @persistent = params[:persistent] if params.key?(:persistent)
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
    # note that the raw response
    #                 from the search engine is converted to JSON by SerpApi.com backend.
    #                 thus, most of the compute power is on the backsdend and not on the client side.
    # @param [Hash] params includes engine, api_key, search fields and more..
    #                this override the default params provided to the constructor.
    # @return [Hash] search results formatted as a Hash.
    def search(params = {})
      get('/search', :json, params)
    end

    # html search perform a search using SerpApi.com
    #  the output is raw HTML from the search engine.
    #  it is useful for training AI models, RAG, debugging
    #   or when you need to parse the HTML yourself.
    #
    # @return [String] raw html search results directly from the search engine.
    def html(params = {})
      get('/search', :html, params)
    end

    # Get location using Location API
    #
    # example: spec/serpapi/location_api_spec.rb
    # doc: https://serpapi.com/locations-api
    #
    # @param [Hash] params must includes fields: q, limit
    # @return [Array<Hash>] list of matching locations
    def location(params = {})
      get('/locations.json', :json, params)
    end

    # Retrieve search result from the Search Archive API
    #
    # ```ruby
    # client = SerpApi::Client.new(engine: 'google', api_key: ENV['SERPAPI_KEY'])
    # results = client.search(q: 'Coffee', location: 'Portland')
    # search_id = results[:search_metadata][:id]
    # archive_search = client.search_archive(search_id)
    # ```
    # example: spec/serpapi/client/search_archive_api_spec.rb
    # doc: https://serpapi.com/search-archive-api
    #
    # @param [String|Integer] search_id from original search `results[:search_metadata][:id]`
    # @param [Symbol] format :json or :html [default: json, optional]
    # @return [String|Hash] raw html or JSON / Hash
    def search_archive(search_id, format = :json)
      raise SerpApiError, 'format must be json or html' unless [:json, :html].include?(format)

      get("/searches/#{search_id}.#{format}", format)
    end

    # Get account information using Account API
    #
    # example: spec/serpapi/client/account_api_spec.rb
    # doc: https://serpapi.com/account-api
    #
    # @param [String] api_key secret key [optional if already provided to the constructor]
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
      q = @params.clone.merge(params)

      # do not pollute default params with custom params
      q.delete(:symbolize_names) if q.key?(:symbolize_names)

      # delete empty key/value
      q.compact
    end

    # @return [Boolean] HTTP session persistent enabled
    def persistent?
      persistent
    end

    # Perform HTTP GET request to the SerpApi.com backend endpoint.
    #
    # @param [String] endpoint HTTP service URI
    # @param [Symbol] decoder type :json or :html
    # @param [Hash] params custom search inputs
    # @return [String|Hash] raw HTML or decoded response as JSON / Hash
    def get(endpoint, decoder = :json, params = {})
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
        begin
          # user can turn on/off JSON keys to symbols
          # this is more memory efficient, but not always needed
          symbolize_names = params.key?(:symbolize_names) ? params[:symbolize_names] : true

          # parse JSON response with Ruby standard library
          data = JSON.parse(response.body, symbolize_names: symbolize_names)
          if data.instance_of?(Hash) && data.key?(:error)
            raise SerpApiError, "HTTP request failed with error: #{data[:error]} from url: https://#{BACKEND}#{endpoint}, params: #{params}, decoder: #{decoder}, response status: #{response.status} "
          elsif response.status != 200
            raise SerpApiError, "HTTP request failed with response status: #{response.status} reponse: #{data} on get url: https://#{BACKEND}#{endpoint}, params: #{params}, decoder: #{decoder}"
          end
        rescue JSON::ParserError
          raise SerpApiError, "JSON parse error: #{response.body} on get url: https://#{BACKEND}#{endpoint}, params: #{params}, decoder: #{decoder}, response status: #{response.status}"
        end

        # discard response body
        response.flush if persistent?

        data
      when :html
        # html decoder
        if response.status != 200
          raise SerpApiError, "HTTP request failed with response status: #{response.status} reponse: #{data} on get url: https://#{BACKEND}#{endpoint}, params: #{params}, decoder: #{decoder}"
        end

        response.body
      else
        raise SerpApiError, "not supported decoder: #{decoder}, available: :json, :html"
      end
    end
  end
end
