##
# Main User model. Stores inforation about all users that can access to the portal.
class Anubis::Tenant::User < ApplicationRecord
  # @!attribute patronymic
  #   @return [String] user's patronymic

  # @!attribute login
  #   @return [String] user's full login with {Tenant#ident} suffix.

  has_secure_password

  # Redefines default table name
  self.table_name = 'users'

  before_validation :before_validation_anubis_user_on_create, on: :create
  before_validation :before_validation_anubis_user_on_update, on: :update
  before_save :before_save_anubis_user
  before_destroy :before_destroy_anubis_user
  after_destroy :after_destroy_anubis_user

  # Email must be valid email address
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  # @!attribute email
  #   @return [String] user's email
  validates :email, presence: true, length: { maximum: 50 }, format: { with: VALID_EMAIL_REGEX }
  validates :email, uniqueness: { case_sensitive: true, scope: [:tenant_id] }, if: :email_unique

  # @!attribute name
  #   @return [String] user's name
  validates :name, length: { maximum: 100 }
  validates :name, presence: true, if: :name_presence

  # @!attribute surname
  #   @return [String] user's surname
  validates :surname, length: { maximum: 100 }
  validates :surname, presence: true, if: :name_presence

  validates :password, length: { in: 5..30 }, on: [:create]
  validates :password, length: { in: 5..30 }, on: [:update], if: :password_changed?
  validates :password_confirmation, length: { in: 5..30 }, on: [:create]
  validates :password_confirmation, length: { in: 5..30 }, on: [:update], if: :password_changed?

  # @!attribute auth_key
  #   @return [String] user's auth key. Variable is used for storing key to restore password or confirm email.
  validates :auth_key, length: { maximum: 32 }

  # @!attribute auth_key
  #   @return [Integer] user's session timeout. Default vaule is 3600
  validates :timeout, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  # @!attribute uuid_bin
  #   @return [Blob] user's binary representation of UUID
  validates :uuid_bin, uniqueness: { case_sensitive: false, scope: [:tenant_id] }

  # @!attribute status
  #   @return ['enabled', 'disabled'] the status of menu element.
  #     - 'enabled' --- user is enabled and can login to system.
  #     - 'disabled' --- user is disabled and can't login to system.
  #     - 'pending' --- user isn't confirmed.
  enum status: {enabled: 0, disabled: 1, pending: 2}

  # @!attribute uuid
  #   @return [String] user's UUID
  attr_accessor :uuid

  # @!attribute groups_access
  #   @return [Array] array of user access groups
  attr_accessor :groups_access

  # @!attribute tenant
  #   @return [Tenant] the tenant that owns this user.
  belongs_to :tenant, class_name: 'Anubis::Tenant::Tenant'
  has_many :user_groups, class_name: 'Anubis::Tenant::UserGroup'

  has_one_attached :avatar

  ##
  # Is called before validation when new user is being created. Checks user parameters before create new user.
  # Generates new UUID. Sets default system parameters for first user.
  def before_validation_anubis_user_on_create
    self.uuid = self.new_uuid
    if self.id
      if self.id == 1
        self.password = 'admin'
        self.password_confirmation = 'admin'
        self.status = 0
        self.tenant_id = 1
        self.timeout = 3600
        return true
      end
    end
    validate_anubis_user true
  end

  ##
  # Is called before validation when user is being updated. Checks user parameters before create new user.
  # Generates new UUID. Sets default system parameters for first user.
  def before_validation_anubis_user_on_update
    validate_anubis_user false
  end

  ##
  # Validates users element. Sets default missing parameters. Prevents changing tenant for existing user.
  # @param is_new [Boolean] sets into true when user is being created
  def validate_anubis_user(is_new)
    self.locale = 'ru-RU' if !self.locale
    self.timeout = 3600 if !self.timeout
    self.tenant_id = self.tenant_id_was if !is_new # Can't change tenant for existing user
    self.status = 0 if self.id == 1 # Can't disable Main Administrator

    if !password.blank?
      if password != password_confirmation
        errors.add(:password, I18n.t('users.errors.different_passwords'))
        errors.add(:password_confirmation, I18n.t('users.errors.different_passwords'))
        return false
      end
    end

    return true
  end

  ##
  # Is called before user will be stored in database. Changes {#login} and {#email} values to lower case.
  # Deletes user cache in Redis database when user's parameters has been changed.
  def before_save_anubis_user
    self.timezone = 'GMT' if !self.timezone
    self.email = self.email.downcase
    self.login = self.email+'.'+self.tenant.ident
    self.redis.del(self.redis_prefix + 'user:' + self.uuid) if self.redis
  end

  ##
  # Checks if password has been changed
  # @return [Boolean] return true if password has been changed
  def password_changed?
    !password.blank?
  end

  ##
  # Is called before delete user from database. Destroys all access groups for this user
  def before_destroy_anubis_user
    if self.id == 1
      errors.add(:base, I18n.t('users.errors.cant_destroy_tenant_admin'))
      throw(:abort, __method__)
    end

    Anubis::Tenant::UserGroup.where(user_id: self.id).delete_all
  end

  ##
  # Is called after user was deleted from database. Also deletes all cache for this user from Redis database.
  def after_destroy_anubis_user
    if self.redis
      self.redis.del self.uuid
      self.redis.keys(self.uuid+'_*').each do |data|
        self.redis.del data
      end
    end
  end

  ##
  # UUID representations in string format
  # @return [String] string representaion of user UUID
  def uuid
    self.bin_to_uuid self.uuid_bin
  end

  ##
  # Sets UUID into binary format
  # @param value [String] string representation of UUID
  def uuid=(value)
    self.uuid_bin = self.uuid_to_bin value
  end

  ##
  # Excludes password from json output and uuid_bin from
  # @param options [Hash] additional options
  def to_json(options={})
    options[:except] ||= [:password_digest, :uuid_bin]
    super(options)
  end

  ##
  # Returns user model system title
  # @return [String] user system title
  def sys_title
    self.title
  end

  ##
  # Attach groups to user json outputs
  def as_json(options={})
    h = super(options)
    h[:groups_access] = []
    self.user_groups.each do |ug|
      h[:groups_access].push ug.group.full_ident
    end
    h
  end

  ##
  # Array of user access group
  def groups_access
    @groups_access ||= get_groups_access
  end

  ##
  # Generate user access groups
  def get_groups_access
    h = []
    self.user_groups.each do |ug|
      h[:groups_access].push ug.group.full_ident
    end
    h
  end

  def name_presence
    true
  end

  def email_unique
    true
  end
end