class Anoubis::RedisServices::Set < Anoubis::ApplicationService
  include Anoubis::RedisServices::Init

  def initialize(key, data)
    @key = "#{redis_prefix}#{key}"
    @data = data
  end

  def call
    if (@data.class == Array) || (@data.class == Hash)
      redis.set(@key, @data.to_json) == 'OK'
    else
      redis.set(@key, @data) == 'OK'
    end
  end
end