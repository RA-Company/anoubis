## Main application model record class inherited from {https://api.rubyonrails.org/classes/ActiveRecord/Base.html ActiveRecord::Base}
class Anoubis::ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  ## Redis database variable
  attr_accessor :redis

  ##
  # Returns {https://github.com/redis/redis-rb Redis database} class
  # @return [Class] {https://github.com/redis/redis-rb Redis} class reference
  def redis
    @redis ||= Redis.new
  end

  ##
  # Returns {https://github.com/redis/redis-rb Redis} prefix for storing cache data. Prefix can be set in Rails.configuration.anoubis_redis_prefix configuration parameter.
  # @return [String] {https://github.com/redis/redis-rb Redis} prefix
  def redis_prefix
    begin
      value = Rails.configuration.redis_prefix
    rescue
      return ''
    end
    return value + ':'
  end

  ##
  # Returns {https://github.com/redis/redis-rb Redis} prefix for storing cache data. Prefix can be set in Rails.configuration.anoubis_redis_prefix configuration parameter.
  # @return [String] {https://github.com/redis/redis-rb Redis} prefix
  def self.redis_prefix
    begin
      value = Rails.configuration.redis_prefix
    rescue
      return ''
    end
    return value + ':'
  end
end
