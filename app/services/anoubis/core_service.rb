class Anoubis::CoreService
  attr_accessor :redis

  def initialize
    self.redis = Redis.new
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