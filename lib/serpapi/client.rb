# Client implementation for SerpApi.com
#
module SerpApi
  # Client for SerpApi.com
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
    #
    # Example:
    # ```ruby
    # require 'serpapi'
    # client = SerpApi::Client.new(api_key: "secure API key", engine: "google", timeout: 30)
    # result = client.search(q: "coffee")
    # ```
    # The params hash should contains the following optional field:
    #  api_key [String] user secret API key
    #  engine [String] search enginge selected
    #  timeout [Integer] HTTP read max timeout in seconds (default: 120s)
    #
    # key can be either a symbol or a string.
    #
    # @param [Hash] params default for the search
    def initialize(params = {})
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

      # set default serpapi related parameters
      @params = params.clone || {}

      # track ruby library as a client for statistic purpose
      @params[:source] = 'serpapi-ruby:' << SerpApi::VERSION

      @params.freeze

      # create connection socket
      return unless persistent?

      @socket = HTTP.persistent("https://#{BACKEND}")
    end

    # perform a search using SerpApi.com
    #
    # @param [Hash] params search includes engine, api_key, search fields and more..
    #                this override the default params set in the constructor.
    # @return [Hash] search results formatted as a Hash.
    #                 note that the raw response
    #                 from the search engine is converted to JSON by SerpApi.com backend.
    #                 thus, most of the compute power is on the backkend and not on the client side.
    #
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
    # @param [Hash] params must includes fields: q, limit
    # @return [Array<Hash>] list of matching location
    #
    # example: spec/serpapi/location_api_spec.rb
    def location(params = {})
      get('/locations.json', :json, params)
    end

    # Retrieve search result from the Search Archive API
    #
    # @param [String|Integer] search_id is returned
    # @param [Symbol] format :json or :html (default: json, optional)
    # @return [String|Hash] raw html or JSON / Hash
    def search_archive(search_id, format = :json)
      raise SerpApiError, 'format must be json or html' unless [:json, :html].include?(format)

      get("/searches/#{search_id}.#{format}", format)
    end

    # Get account information using Account API
    # @param [String] api_key secret key
    def account(api_key = nil)
      params = (api_key.nil? ? {} : { api_key: api_key })
      get('/account', :json, params)
    end

    # @return [String] default search engine
    def engine
      @params[:engine]
    end

    # @return [String] api_key user secret api_key as supplied in the constructor params[:api_key]
    def api_key
      @params[:api_key]
    end

    # close open connection
    def close
      @socket.close if @socket
    end

    private

    # @return [Hash] query parameter
    def query(params)
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
