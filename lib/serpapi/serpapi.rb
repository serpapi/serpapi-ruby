# SerpApi module provides serpapi.com client
#
module SerpApi
  # Client for SerpApi.com
  #
  class Client
    VERSION = '1.0.0'.freeze
    BACKEND = 'serpapi.com'.freeze

    # search parameter
    attr_accessor :parameter
    # HTTP read timeout
    attr_accessor :read_timeout

    # constructor
    #
    # Example:
    # ```ruby
    # require 'serpapi'
    # client = SerpApi::Client.new(api_key: "secure API key", engine: "google")
    # result = client.search(q: "coffee")
    # ```
    # parameter:
    #  engine [String] search enginge selected
    #  api_key [String] user secret API key
    #  read_timeout [Integer] HTTP read max timeout
    #
    # @param [Hash] parameter default
    def initialize(parameter = {})
      # set default paramter
      @default = parameter || {}

      # set default read timeout
      @read_timeout = parameter[:read_timeout] || 100
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
      start('/search', :json, parameter)
    end

    # html search
    #
    # @return [String] raw html search results directly from the search engine
    def html(parameter = {})
      start('/search', :html, parameter)
    end

    # Get location using Location API
    #
    # @param [Hash] parameter must includes fields q, limit
    # @return [Array<Hash>] list of matching location
    #
    # example: spec/serpapi/location_api_spec.rb
    def location(parameter = {})
      start('/locations.json', :json, parameter)
    end

    # Retrieve search result from the Search Archive API
    #
    # @param [String|Integer] search_id is returned
    # @param [Symbol] format :json or :html (default: json, optional)
    # @return [String|Hash] raw html or
    #
    def search_archive(search_id, format = :json)
      raise SerpApiException, 'format must be json or html' unless %i[json html].include?(format)
      start("/searches/#{search_id}.#{format}", format, nil)
    end

    # Get account information using Account API
    # @param [String] optional api_key secret key
    def account(api_key = nil)
      parameter = (api_key.nil? ? {} : { api_key: api_key })
      start('/account', :json, parameter)
    end

    # @return [String] default search engine
    def engine
      @default['engine'] || @default[:engine]
    end

    # @return [Hash] default parameter
    def parameter
      @default
    end

    # @return [String] api_key default search key
    def api_key
      @default['api_key'] || @default[:api_key]
    end

    private

    # build url
    #
    def build_url(path, parameter)
      # force default
      param = (@default || {}).merge(parameter || {})

      # set ruby client
      param[:source] = 'ruby'

      # delete empty key/value
      param.delete_if { |_, value| value.nil? }

      # HTTP parameter encoding
      q = URI.encode_www_form(param)

      # return URL
      URI::HTTPS.build(host: BACKEND, path: path, query: q)
    end

    # start HTTP query
    def start(path, decoder = :json, parameter = {})
      url = build_url(path, parameter)
      payload = get(url)
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

    # get URL content
    def get(url)
      URI(url).open(read_timeout: read_timeout).read
    end

    # decode payload using json or html
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
