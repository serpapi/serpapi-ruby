# Client implementation for SerpApi.com
# frozen_string_literal: true

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
    BACKEND = 'serpapi.com'

    # HTTP timeout requests
    attr_reader :timeout,
                # Query parameters
                :params,
                # HTTP persistent
                :persistent,
                # raise on search-level error (HTTP 200 with an `error` field)
                :raise_on_search_error,
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
    # * `persistent`: [Boolean] Keep socket connection open to save on SSL handshake / connection reconnection (2x
    # faster). [default: true]
    # * `async`: [Boolean] Support non-blocking job submission. [default: false]
    # * `timeout`: [Integer] HTTP get max timeout in seconds. Applied in both persistent and non-persistent
    # mode. [default: 120s == 2m]
    # * `symbolize_names`: [Boolean] Convert JSON keys to symbols. [default: true]
    # * `raise_on_search_error`: [Boolean] Raise a `SerpApiError` when the backend returns HTTP 200 with an
    # `error` field (e.g. "no results"). When false, the error payload is returned to the caller instead.
    # [default: true]
    #
    # **Key:**
    #
    # The `key` parameter can be either a symbol or a string.
    #
    # **Note:**
    #
    # * All parameters are optional.
    # * The input hash is not mutated; a private copy is kept by the client.
    # * The `close` method should be called when the client is no longer needed.
    #
    # @param [Hash] params default for the search
    #
    def initialize(params = {})
      raise SerpApiError, 'params cannot be nil' if params.nil?
      raise SerpApiError, "params must be hash, not: #{params.class}" unless params.instance_of?(Hash)

      # work on a private copy so the caller's hash is never mutated
      options = params.dup

      # store client HTTP request timeout
      @timeout = options.delete(:timeout) || 120

      # enable HTTP persistent mode (default: true)
      @persistent = options.key?(:persistent) ? options.delete(:persistent) : true

      # raise on search-level errors by default (back-compatible)
      @raise_on_search_error = options.key?(:raise_on_search_error) ? options.delete(:raise_on_search_error) : true

      # set default query parameters (timeout / persistent / raise_on_search_error are client options, not query params)
      @params = options

      # track ruby library as a client for statistic purpose
      @params[:source] ||= "serpapi-ruby:#{SerpApi::VERSION}"

      # ensure default parameter would not be modified later
      @params.freeze

      # create connection socket
      return unless persistent?

      # NOTE: the timeout must be set on the chain *before* `.persistent`,
      #       otherwise it is silently ignored on the persistent connection.
      @socket = HTTP.timeout(@timeout).persistent("https://#{BACKEND}")
    end

    # perform a search using SerpApi.com
    #
    # see: https://serpapi.com/search-api
    #
    # note that the raw response
    #                 from the search engine is converted to JSON by SerpApi.com backend.
    #                 thus, most of the compute power is on the backend and not on the client side.
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
    # By default a search that was archived *with* an `error` field (e.g. a query that
    # returned no results) is returned as-is rather than raised, so the archived record
    # can be inspected. Pass `raise_on_search_error: true` to restore the raising behavior.
    # see: https://github.com/serpapi/serpapi-ruby/issues/17
    #
    # @param [String|Integer] search_id from original search `results[:search_metadata][:id]`
    # @param [Symbol] format :json or :html [default: json, optional]
    # @param [Boolean] raise_on_search_error raise on an archived search-level error [default: false]
    # @return [String|Hash] raw html or JSON / Hash
    def search_archive(search_id, format = :json, raise_on_search_error: false)
      raise SerpApiError, 'format must be json or html' unless %i[json html].include?(format)

      get("/searches/#{search_id}.#{format}", format, { raise_on_search_error: raise_on_search_error })
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

    def inspect
      masked_key = api_key && (api_key.length > 8 ? "#{api_key[..3]}****#{api_key[-4..]}" : '****')
      "#<#{self.class} @engine=#{engine} @timeout=#{timeout} @persistent=#{persistent} api_key=#{masked_key}>"
    end

    private

    # @param [Hash] params to merge with default parameters provided to the constructor.
    # @return [Hash] merged query parameters after cleanup
    def query(params)
      raise SerpApiError, "params must be hash, not: #{params.class}" unless params.instance_of?(Hash)

      # merge default params with custom params (merge returns a fresh hash; @params is left untouched)
      q = @params.merge(params)

      # drop client-only options so they are never sent to the backend
      q.delete(:symbolize_names)
      q.delete(:raise_on_search_error)

      # delete empty key/value in place (avoids a second hash allocation on the hot path)
      q.compact!
      q
    end

    # @return [Boolean] HTTP session persistent enabled
    def persistent?
      persistent
    end

    # Resolve the symbolize_names option with precedence: per-call > constructor default > true.
    def symbolize_names?(params)
      return params[:symbolize_names] if params.key?(:symbolize_names)

      @params.fetch(:symbolize_names, true)
    end

    # Resolve the raise_on_search_error option with precedence: per-call > constructor default.
    def raise_on_search_error?(params)
      return params[:raise_on_search_error] if params.key?(:raise_on_search_error)

      @raise_on_search_error
    end

    # Perform HTTP GET request to the SerpApi.com backend endpoint.
    #
    # @param [String] endpoint HTTP service URI
    # @param [Symbol] decoder type :json or :html
    # @param [Hash] params custom search inputs
    # @return [String|Hash] raw HTML or decoded response as JSON / Hash
    def get(endpoint, decoder = :json, params = {})
      response = execute_request(endpoint, params)
      handle_response(response, decoder, endpoint, params)
    end

    def execute_request(endpoint, params)
      if persistent?
        @socket.get(endpoint, params: query(params))
      else
        url = "https://#{BACKEND}#{endpoint}"
        HTTP.timeout(@timeout).get(url, params: query(params))
      end
    end

    def handle_response(response, decoder, endpoint, params)
      case decoder
      when :json
        process_json_response(response, endpoint, params)
      when :html
        process_html_response(response, endpoint, params)
      else
        raise SerpApiError, "not supported decoder: #{decoder}, available: :json, :html"
      end
    end

    def process_json_response(response, endpoint, params)
      begin
        data = JSON.parse(response.body.to_s, symbolize_names: symbolize_names?(params))
        validate_json_content!(data, response, endpoint, params)
      rescue JSON::ParserError
        raise_parser_error(response, endpoint, params)
      end

      response.flush if persistent?
      data
    end

    def process_html_response(response, endpoint, params)
      raise_http_error(response, nil, endpoint, params, decoder: :html) if response.status != 200

      # read the full body to a String *and* drain the socket so the persistent
      # connection can be safely reused for the next request (parity with JSON).
      body = response.body.to_s
      response.flush if persistent?
      body
    end

    def validate_json_content!(data, response, endpoint, params)
      explicit_error = data.is_a?(Hash) ? data[:error] : nil

      # raise on a transport error (non-200), or on a search-level error
      # (HTTP 200 with an `error` field) only when the caller opted in.
      http_error = response.status != 200
      search_error = explicit_error && raise_on_search_error?(params)
      return unless http_error || search_error

      raise_http_error(response, data, endpoint, params, explicit_error: explicit_error)
    end

    # Centralized error raising to clean up the logic methods
    def raise_http_error(response, data, endpoint, params, explicit_error: nil, decoder: :json)
      msg = "HTTP request failed with status: #{response.status}"
      msg += " error: #{explicit_error}" if explicit_error

      raise SerpApiError.new(
        "#{msg} from url: https://#{BACKEND}#{endpoint}",
        serpapi_error: explicit_error || (data.is_a?(Hash) ? data[:error] : nil),
        search_params: params,
        response_status: response.status,
        search_id: data.is_a?(Hash) ? data&.dig(:search_metadata, :id) : nil,
        decoder: decoder
      )
    end

    def raise_parser_error(response, endpoint, params)
      raise SerpApiError.new(
        "JSON parse error: #{response.body} on get url: https://#{BACKEND}#{endpoint}",
        search_params: params,
        response_status: response.status,
        decoder: :json
      )
    end
  end
end
