class Anubis::Sso::Server::User < Anubis::Core::ApplicationRecord
  has_secure_password

  self.table_name = 'users'

  before_validation :before_validation_anubis_sso_server_user_on_create, on: :create
  before_save :before_save_anubis_sso_server_user
  after_destroy :after_destroy_anubis_sso_server_user

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :login, presence: true, length: { maximum: 50 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: true }

  validates :name, presence: true, length: { maximum: 100 }
  validates :surname, presence: true, length: { maximum: 100 }

  validates :password, length: { in: 5..30 }, on: [:create]
  validates :password, length: { in: 5..30 }, on: [:update], if: :password_changed?
  validates :password_confirmation, length: { in: 5..30 }, on: [:create]
  validates :password_confirmation, length: { in: 5..30 }, on: [:update], if: :password_changed?

  validates :auth_key, length: { maximum: 32 }

  validates :timeout, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 300 }

  validates :uuid, presence: true, length: { maximum: 40 }, uniqueness: { case_sensitive: true }

  enum status: { pending: 0, enabled: 1, disabled: 100 }
  validates :status, inclusion: { in: self.statuses }

  enum role: { user_role: 0, admin_role: 100 }
  validates :role, inclusion: { in: self.roles }

  def before_validation_anubis_sso_server_user_on_create
    self.uuid = SecureRandom.uuid
    self.timezone = 'GMT' if !self.timezone
  end

  def before_save_anubis_sso_server_user
    self.timezone = 'GMT' if !self.timezone
    self.login = self.login.downcase
    self.clear_cache
  end

  def after_destroy_anubis_sso_server_user
    self.clear_cache
  end

  def save_cache
    self.redis.set(self.redis_prefix + 'user:' + self.uuid, self.to_json(except: [:password_digest])) if self.redis
  end

  def clear_cache
    self.redis.del(self.redis_prefix + 'user:' + self.uuid) if self.redis
  end

  def password_changed?
    !password.blank?
  end

  def self.load_cache(redis, uuid)
    begin
      data = JSON.parse redis.get(User.redis_prefix + 'user:' + uuid), { symbolize_names: true }
    rescue
      data = nil
    end

    unless data
      user = self.where(uuid: uuid).first
      if user
        return JSON.parse(user.to_json(except: [:password_digest]), { symbolize_names: true })
      end
    end

    data
  end
end
