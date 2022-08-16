class Anoubis::RedisServices::Set < Anoubis::ApplicationService
  include Anoubis::RedisServices::Init

  def initialize(key, data, time = nil)
    @key = "#{redis_prefix}#{key}"
    @data = data
    @time = time
  end

  def call
    if (@data.class == Array) || (@data.class == Hash)
      redis.set(@key, @data.to_json, ex: @time) == 'OK'
    else
      redis.set(@key, @data, ex: @time) == 'OK'
    end
  end
end