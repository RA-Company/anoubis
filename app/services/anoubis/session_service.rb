class Anoubis::SessionService < Anoubis::CoreService
  ##
  # Initialize session service.
  # @param options [Hash] array of parameters
  def initialize(options = {})
    super options
  end

  def clear
    redis.scan_each(:match => self.redis_prefix + 'session:*') do |key|
      begin
        data = JSON.parse redis.get(key), { symbolize_names: true }
      rescue
        data = {}
      end

      data[:ttl] = Time.now - 1.day unless data.key? :ttl
      redis.del(key) if data[:ttl] < Time.now
    end
  end
end