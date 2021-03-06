##
# Request service
class Anoubis::RequestService < Anoubis::CoreService
  ## Log service {Anoubis::LogService}
  attr_accessor :log

  ## Cookies data for current session
  attr_accessor :cookies

  ##
  # Setups basic initialization parameters.
  # @param options [Hash] array of initial parameters
  # @option options [Anoubis::LogService] :log Log service
  def initialize(options = {})
    @cookies = nil
    options = {} unless options
    options = {} unless options.class == Hash
    options[:log] = Anoubis::LogService.new unless options.key? :log
    self.log = options[:log] ? options[:log] : Anoubis::LogService.new
    super options
  end

  ##
  # Returns cookies data for current session
  # @return [Hash] Cookies data
  def cookies
    return @cookies if @cookies

    @cookies = redis.get cookie_path
    if @cookies
      begin
        @cookies = JSON.parse(self.cookies, { symbolize_names: true })
      rescue
        @cookies = {}
      end
    else
      @cookies = {}
    end

    @cookies
  end

  ##
  # Setups cookies data for current session
  # @param data [Hash] Defined cookies parameters
  def cookies=(data)
    @cookies = data
    store_cookies
  end

  ##
  # Returns redis path for storing cookies data
  # @return [String] Redis storing path
  def cookie_path
    redis_prefix + 'cookies'
  end

  ##
  # Store current cookies to {https://github.com/redis/redis-rb Redis} cache
  def store_cookies
    redis.set cookie_path, @cookies.to_json
  end

  ##
  # Unzip {https://www.rubydoc.info/gems/rest-client/RestClient RestClient} response data if returned data is GZipped
  # @param response [RestClient::RawResponse] Received {https://www.rubydoc.info/gems/rest-client/RestClient/RawResponse RestClient::RawResponse}
  # @return [String] Unzipped string
  def unzip(response)
    result = response.body
    begin
      if response.headers.key? :content_encoding
        if response.headers[:content_encoding] == 'gzip'
          sio = StringIO.new( response.body )
          gz = Zlib::GzipReader.new( sio )
          result = gz.read()
        end
      end
    rescue => e
      self.log 'Error was received when page encoded. ' + e.to_s, 'debug'
      result = nil
    end

    result
  end

  ##
  # Store data to file
  # @param file_name [String] Name of file
  # @param text [String] Saved text
  def store(file_name, text)
    file = File.open(file_name, "w")
    file.write(text)
    file.close
  end

  ##
  # Transform cookies string to hash
  # @param str [String] Cookies string
  # @return [Hash] Cookies data
  def parse_cookie(str)
    cookies = { }

    arr = str.split('; ')
    arr.each do |line|
      index = line.index '='
      if index
        key = line[0..(index - 1)]
        value = line[(index + 1)..(line.length - 1)]
      end
      cookies[key.to_s.to_sym] = value.to_s
    end

    cookies
  end
end