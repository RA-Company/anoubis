module Anoubis::RedisServices::Init
  # @!attribute default_host
  #   @return [String] default Redis database host (default: 127.0.0.1)
  attr_accessor :redis_host
  # @!attribute default_host
  #   @return [String] default Redis database port (default: 6379)
  attr_accessor :redis_port
  # @!attribute default_db
  #   @return [String] default redis database (default: 0)
  attr_accessor :redis_db
  # @!attribute default_prefix
  #  @return [String] default redis prefix (default: '')
  attr_accessor :redis_prefix

  def setup
    begin
      @redis_host = Rails.configuration.redis_host
    rescue
      @redis_host = '127.0.0.1'
    end

    begin
      @redis_port = Rails.configuration.redis_port
    rescue
      @redis_port = 6379
    end

    begin
      self.redis_prefix = Rails.configuration.redis_prefix
    rescue
      @redis_prefix = ''
    end

    begin
      @redis_db = Rails.configuration.redis_db.to_s.to_i
    rescue
      @redis_db = 0
    end
  end

  ##
  # Set Redis prefix
  # @param [String] value Redis prefix
  def redis_prefix=(value)
    @redis_prefix = '' and return if value == nil
    @redis_prefix = '' and return if value.to_s == ''

    @redis_prefix = "#{value}:"
  end

  ##
  # Return Redis database connection according by defined parameters
  # @return [Redis] Redis database connection
  def redis
    Redis.new( host: redis_host, port: redis_port, db: redis_db )
  end
end