class Anoubis::Sso::Server::System < Anoubis::Core::ApplicationRecord
  self.table_name = 'systems'

  before_validation :before_validation_anoubis_sso_server_system_on_create, on: :create
  after_save :after_save_anoubis_sso_server_system
  after_destroy :after_destroy_anoubis_sso_server_system

  #VALID_HTTP_REGEX = /\A(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.-]*)*\/?\Z/i

  validates :title, presence: true, length: { maximum: 100 }
  validates :host, presence: true, length: { maximum: 200 }#, format: { with: VALID_HTTP_REGEX }
  validates :uuid, presence: true, length: { maximum: 40 }, uniqueness: { case_sensitive: true }

  enum status: { enabled: 0, disabled: 1 }

  def before_validation_anoubis_sso_server_system_on_create
    self.uuid = SecureRandom.uuid unless self.uuid
    self.secret_key = SecureRandom.uuid unless self.secret_key
  end

  def after_save_anoubis_sso_server_system
    if self.status == 'enabled'
      self.redis.set self.redis_cache_name, { host: self.host, secret_key: self.secret_key, callback: self.callback, silent: self.silent }.to_json
    else
      self.after_destroy_system
    end
  end

  def after_destroy_anubis_sso_server_system
    self.redis.del self.redis_cache_name
  end

  def redis_cache_name
    self.redis_prefix + 'system:' + self.uuid
  end
end
