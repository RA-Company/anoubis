class Anoubis::RedisServices::Get < Anoubis::ApplicationService
  include Anoubis::RedisServices::Init

  def initialize(key)
    @key = "#{redis_prefix}#{key}"
  end

  def call
    redis.get(@key)
  end
end