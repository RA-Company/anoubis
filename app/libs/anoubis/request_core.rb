##
# Request service
class Anoubis::RequestCore
  ## Cookies data for current session
  attr_accessor :cookies

  ##
  # Returns cookies path
  # @return [String] Cookies path
  def cookie_path
    'cookies'
  end

  ##
  # Setups basic initialization parameters.
  # @param options [Hash] array of initial parameters
  # @option options [Anoubis::LogService] :log Log service
  def initialize(options = {})
    @cookies = nil
  end

  ##
  # Returns cookies data for current session
  # @return [Hash] Cookies data
  def cookies
    return @cookies if @cookies

    @cookies = Anoubis::RedisServices::GetJson.call(cookie_path)
    @cookies = {} unless @cookies

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
  # Store current cookies to {https://github.com/redis/redis-rb Redis} cache
  def store_cookies
    Anoubis::RedisServices::Set.call(cookie_path, cookies)
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