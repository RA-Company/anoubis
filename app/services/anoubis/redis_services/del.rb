class Anoubis::RedisServices::Del < Anoubis::RedisServices::Init
  def initialize(key)
    super key

    if key.class == Array
      @key = []
      key.each do |item|
        @key.push "#{redis_prefix}#{item}"
      end
    else
      @key = "#{redis_prefix}#{key}"
    end
  end

  def key
    @key
  end

  def call
    if @key.class == Array
      redis.del(*@key)
    else
      redis.del(@key)
    end
  end
end