module Anoubis::RedisServices::Init
  def redis
    Redis.new( host: redis_host, port: redis_port )
  end

  def redis_host
    begin
      value = Rails.configuration.redis_host
    rescue
      value = '127.0.0.1'
    end

    value
  end

  def redis_port
    begin
      value = Rails.configuration.redis_port
    rescue
      value = 6379
    end

    value
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