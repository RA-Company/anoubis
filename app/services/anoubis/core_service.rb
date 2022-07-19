class Anoubis::CoreService
  attr_accessor :redis

  ##
  # Returns defined {https://github.com/redis/redis-rb Redis} server host (By default return 127.0.0.1)
  # @return [String] {https://github.com/redis/redis-rb Redis} server host
  def redis_host
    begin
      value = Rails.configuration.anoubis_redis_host
    rescue
      value = '127.0.0.1'
    end

    value
  end

  ##
  # Returns defined {https://github.com/redis/redis-rb Redis} server port (By default return 6379)
  # @return [Number] {https://github.com/redis/redis-rb Redis} server port
  def redis_port
    begin
      value = Rails.configuration.anoubis_redis_port
    rescue
      value = 6379
    end

    value
  end

  def initialize
    self.redis = Redis.new( host: redis_host, port: redis_port )
  end

  def redis_prefix
    begin
      value = Rails.configuration.redis_prefix
    rescue
      return ''
    end
    return value + ':'
  end
end