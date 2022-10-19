##
# Request service
class Anoubis::RequestCore
  ## Cookies data for current session
  attr_accessor :cookies
  ## Cookies path for store cookies
  attr_accessor :cookies_path

  ##
  # Setups basic initialization parameters.
  # @param options [Hash] array of initial parameters
  # @option options [String] :cookies_path {https://github.com/redis/redis-rb Redis} key identifier to store cookies data (Default: 'cookies')
  def initialize(options = {})
    @cookies = nil
    @cookies_path = options.key?(:cookies_path) ? options[:cookies_path] : 'cookies'
  end

  ##
  # Returns cookies data for current session
  # @return [Hash] Cookies data
  def cookies
    return @cookies if @cookies

    @cookies = Anoubis::RedisServices::GetJson.call(cookies_path)
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
    Anoubis::RedisServices::Set.call(cookies_path, @cookies)
  end
end