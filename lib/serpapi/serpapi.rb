

module SerpApi

# SerpApi.com search client
#
class Client

  VERSION = "1.0.0"
  BACKEND = "serpapi.com"

  attr_accessor :parameter

  # constructor
  #
  # Example:
  # ```ruby
  # require 'google_search'
  # client = SerpApi::Client.new(api_key: "secure API key", engine: "google")
  # result = client.search(q: "coffee")
  # ```
  #
  #  read_timeout is additional
  #
  # @param [Hash] parameter default 
  def initialize(parameter = {})
    # set default paramter
    @default = parameter || {}

    # set default read timeout
    @read_timeout = parameter[:read_timeout] || 100
  end

  # search against serpapi.com
  #
  # @param [Hash] parameter search includes engine, api_key, search fields..
  # @param [String] decoder select :json or :html decoder (optional)
  # @return [Hash] search results formatted as JSON by SerpApi.com
  #
  def search(parameter = {}, decoder = :json)
    run('/search', decoder, parameter)
  end

  # html search 
  #
  # @return [String] raw html search results directly from the search engine
  def html(parameter = {})
    run('/search', :html, parameter)
  end

  # Get location using Location API
  #
  # 
  def location(parameter = {})
    run('/locations.json', :json, parameter)
  end

  # Retrieve search result from the Search Archive API
  # 
  def search_archive(search_id, format = :json, parameter = {})
    raise SerpApiException.new('format must be json or html') if format !~ /^(html|json)$/
    run("/searches/#{search_id}.#{format}", :json, nil)
  end

   # Get account information using Account API
   # @param [String] optional api_key secret key
  def account(api_key = nil)
    parameter = (api_key == nil ? {} : {api_key: api_key} )
    run('/account', :json, parameter)
  end

  # @return [String] default search engine
  def engine
    @default['engine'] || @default[:engine]
  end

  # @return [Hash] default parameter
  def parameter
    @default
  end

  # api_key
  # @param [String] api_key set user secret API key (copy/paste from https://serpapi.com/dashboard)
  def self.api_key=(api_key)
    @default[:api_key] = api_key
  end

  # @return [String] api_key default search key
  def api_key
    @default[:api_key]
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

  # run HTTP query
  def run(path, decoder = :json, parameter)
    begin
      url = build_url(path, parameter)
      payload = URI(url).open(read_timeout: @read_timeout).read

      case decoder
      when :json
        return JSON.parse(payload, symbolize_names: true)
      when :html
        return payload
      else
        raise SerpApiException("not supported decoder #{decoder}. should be: :html, :json")
      end

    rescue OpenURI::HTTPError => e
      data = JSON.load(e.io.read)
      if err = data["error"]
        puts "server returns an error for url: #{url}"
        raise SerpApiException(err)
      else
        puts "fail: fetch url: #{url}"
        raise e
      end
    rescue => e
      puts "fail: fetch url: #{url}"
      raise e
    end
  end

end
end