class Anoubis::RedisServices::Set < Anoubis::RedisServices::Init
  def call(data, time = nil)
    if (data.class == Array) || (data.class == Hash)
      redis.set(key, data.to_json, ex: time) == 'OK'
    else
      redis.set(key, data, ex: time) == 'OK'
    end
  end
end