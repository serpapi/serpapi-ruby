# Client implementation for SerpApi.com
#
module SerpApi

  # Client for SerpApi.com
  #
  class Client
    include Errors

    BACKEND = 'serpapi.com'.freeze

                # HTTP timeout requests
    attr_reader :timeout,
                # Query parameters
                :params

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
      # set default read timeout
      @timeout = params[:timeout] || params['timeout'] || 120
      @timeout.freeze

      # delete this client only configuration keys
      params.delete('timeout') if params.key? 'timeout'
      params.delete(:timeout) if params.key? :timeout

      # set default params safely in memory
      @params = params.clone || {}
      @params.freeze
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
      raise SerpApiException, 'format must be json or html' unless [:json, :html].include?(format)

      get("/searches/#{search_id}.#{format}", format, nil)
    end

    # Get account information using Account API
    # @param [String] api_key secret key
    def account(api_key = nil)
      params = (api_key.nil? ? {} : { api_key: api_key })
      get('/account', :json, params)
    end

    # @return [String] default search engine
    def engine
      @params['engine'] || @params[:engine]
    end

    # @return [String] api_key user secret api_key as supplied in the constructor params[:api_key]
    def api_key
      @params['api_key'] || @params[:api_key]
    end

    private

    # build url from the search params
    #
    # @param [String] endpoint HTTP service uri
    # @param [Hash] params custom search inputs
    # @return formatted HTTPS URL
    def build_url(endpoint, params)
      # force default
      query = (@params || {}).merge(params || {})

      # set ruby client
      query[:source] = 'serpapi-ruby:' << SerpApi::VERSION

      # delete empty key/value
      query.compact!

      # HTTP params encoding
      encoded_query = URI.encode_www_form(query)

      # return URL
      URI::HTTPS.build(host: BACKEND, path: endpoint, query: encoded_query)
    end

    # get HTTP query formatted results
    #
    # @param [String] endpoint HTTP service uri
    # @param [Symbol] decoder type :json or :html
    # @param [Hash] params custom search inputs
    # @return decoded payload as JSON / Hash or String
    def get(endpoint, decoder = :json, params = {})
      url = build_url(endpoint, params)
      payload = URI(url).open(read_timeout: timeout).read
      decode(payload, decoder)
      rescue OpenURI::HTTPError => err
        data = JSON.parse(err.io.read)
        if data.key?('error')
          raise SerpApiException, "error: #{data['error']} from url: #{url}"
        end
        raise SerpApiException, "fail: get url: #{url} response: #{data}"
      rescue => err
        raise SerpApiException, "fail: get url: #{url} caused by: #{err}"
      end
    end

    # decode HTTP payload either as :json or :html
    #
    # @param [String] payload to decode
    # @param [Symbol] decoder type :json or :html
    # @return decoded payload as JSON / Hash or HTML / String
    def decode(payload, decoder)
      case decoder
      when :json
        JSON.parse(payload, symbolize_names: true)
      when :html
        payload
      else
        msg = "not supported decoder #{decoder}. should be: :html or :json (Symbol)"
        raise SerpApiException, msg
      end
    end
end
