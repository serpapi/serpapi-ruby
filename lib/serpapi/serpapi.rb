# SerpApi module provides serpapi.com client
#
module SerpApi

  # Client for SerpApi.com
  #
  class Client
    VERSION = '1.0.0'.freeze
    BACKEND = 'serpapi.com'.freeze

    # HTTP read timeout in seconds (default: 60s)
    attr_accessor :read_timeout

    # Constructor
    #
    # Example:
    # ```ruby
    # require 'serpapi'
    # client = SerpApi::Client.new(api_key: "secure API key", engine: "google", timeout: 30)
    # result = client.search(q: "coffee")
    # ```
    # The parameter hash should contains the following optional field:
    #  api_key [String] user secret API key
    #  engine [String] search enginge selected
    #  timeout [Integer] HTTP read max timeout in seconds (default: 60s)
    #
    # key can be either a symbol or a string.
    #
    # @param [Hash] parameter default for the search
    def initialize(parameter = {})
      # set default read timeout
      @read_timeout = parameter[:timeout] || parameter['timeout'] || 60

      # set default paramter
      @default = parameter.clone || {}
      @default.freeze
    end

    # perform a search using serpapi.com
    #
    # @param [Hash] parameter search includes engine, api_key, search fields and more..
    #                this override the default parameter set in the constructor.
    # @return [Hash] search results formatted as a Hash.
    #                 note that the raw response
    #                 from the search engine is converted to JSON by SerpApi.com backend.
    #                 thus, most of the compute power is not pass on the client.
    #
    def search(parameter = {})
      get('/search', :json, parameter)
    end

    # html search
    #
    # @return [String] raw html search results directly from the search engine
    def html(parameter = {})
      get('/search', :html, parameter)
    end

    # Get location using Location API
    #
    # @param [Hash] parameter must includes fields q, limit
    # @return [Array<Hash>] list of matching location
    #
    # example: spec/serpapi/location_api_spec.rb
    def location(parameter = {})
      get('/locations.json', :json, parameter)
    end

    # Retrieve search result from the Search Archive API
    #
    # @param [String|Integer] search_id is returned
    # @param [Symbol] format :json or :html (default: json, optional)
    # @return [String|Hash] raw html or JSON / Hash
    def search_archive(search_id, format = :json)
      raise SerpApiException, 'format must be json or html' unless %i[json html].include?(format)
      get("/searches/#{search_id}.#{format}", format, nil)
    end

    # Get account information using Account API
    # @param [String] api_key secret key
    def account(api_key = nil)
      parameter = (api_key.nil? ? {} : { api_key: api_key })
      get('/account', :json, parameter)
    end

    # @return [String] default search engine
    def engine
      @default['engine'] || @default[:engine]
    end

    # @return [Hash] parameter default as defined in the constructor
    def default_parameter
      @default
    end

    # @return [String] api_key user secret api_key as supplied in the constructor parameter[:api_key]
    def api_key
      @default['api_key'] || @default[:api_key]
    end

    # @return [Integer] timeout in millisecond HTTP read
    def timeout
      @read_timeout
    end

    private

    # build url from user parameter 
    #
    # @param [String] endpoint HTTP service uri
    # @param [Hash] parameter custom search inputs
    # @return formatted HTTPS URL
    def build_url(endpoint, parameter)
      # force default
      query = (@default || {}).merge(parameter || {})

      # set ruby client
      query[:source] = 'ruby'

      # delete empty key/value
      query.delete_if { |_, value| value.nil? }

      # HTTP parameter encoding
      encoded_query = URI.encode_www_form(query)

      # return URL
      URI::HTTPS.build(host: BACKEND, path: endpoint, query: encoded_query)
    end

    # get HTTP query
    #
    # @param [String] endpoint HTTP service uri
    # @param [:json|:html] decoder type
    # @param [Hash] parameter custom search inputs
    # @return decoded payload as JSON / Hash or String 
    def get(endpoint, decoder = :json, parameter = {})
      url = build_url(endpoint, parameter)
      payload = URI(url).open(read_timeout: @read_timeout).read
      return decode(payload, decoder)
    rescue OpenURI::HTTPError => e
      data = JSON.parse(e.io.read)
      if data.key?('error')
        raise SerpApiException, "error: #{data['error']} from url: #{url}"
      end
      raise SerpApiException, "fail: get url: #{url} response: #{data}"
    rescue => e
      raise SerpApiException, "fail: get url: #{url} caused by: #{e}"
    end

    # decode payload using json or html
    #
    # @param [String] payload to decode
    # @param [:json|:html] decoder type
    # @return decoded payload as JSON / Hash or String 
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
end
