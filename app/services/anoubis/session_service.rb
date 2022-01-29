class Anubis::SessionService < Anubis::CoreService
  def initialize
    super
  end

  def clear
    self.redis.scan_each(:match => self.redis_prefix + 'session:*') do |key|
      begin
        data = JSON.parse redis.get(key), { symbolize_names: true }
      rescue
        data = {}
      end
      data[:ttl] = Time.now - 1.day unless data.key? :ttl
      self.redis.del(key) if data[:ttl] < Time.now
    end
  end
end