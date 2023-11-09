class Anoubis::RedisServices::Init < Anoubis::ApplicationService
  # @!attribute redis_host
  #   @return [String] default Redis database host (default: 127.0.0.1)
  attr_accessor :redis_host
  # @!attribute redis_port
  #  @return [String] default Redis database port (default: 6379)
  attr_accessor :redis_port
  # @!attribute redis_db
  #   @return [String] default redis database (default: 0)
  attr_accessor :redis_db
  # @!attribute redis_password
  #  @return [String] default redis password (default: '')
  attr_accessor :redis_password
  # @!attribute redis_prefix
  #  @return [String] default redis prefix (default: '')
  attr_accessor :redis_prefix
  # @!attribute key
  #   @return [String] Redis key
  attr_accessor :key

  # @!attribute redis
  #   @return [Redis] Redis database connection
  attr_accessor :redis

  ##
  # Initialize service
  # @param [String] key Redis key (default: '')
  def initialize(key = '')
    @key = key

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
      self.redis_password = Rails.configuration.redis_password
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
    @redis ||= get_redis
  end

  private def get_redis
    options = {
      host: redis_host,
      port: redis_port,
      db: redis_db
    }
    options[:password] = redis_password if redis_password != ''

    Redis.new(options)
  end

  ##
  # Return redis key with prefix
  # @return [String] redis key with prefix
  def key
    "#{redis_prefix}#{@key}"
  end
end