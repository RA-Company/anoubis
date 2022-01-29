##
# Tenant model. Stores information about all portal's tenants.
class Anoubis::Tenant::Tenant < Anoubis::Core::ApplicationRecord
  # Redefines default table name
  self.table_name = 'tenants'

  before_validation :before_validation_tenant_create, on: :create
  before_validation :before_validation_tenant_update, on: :update
  before_save :before_save_tenant
  after_create :after_create_tenant
  after_update :after_update_tenant
  before_destroy :before_destroy_tenant

  # Tenant's identifier consists of lowercase alphabetic symbols.
  VALID_TENANT_REGEX = /[a-z]\z/i

  # @!attribute ident
  #   @return [String] the tenant's identifier. Identifier consists of lowercase alphabetical symbols.
  validates :ident, length: { minimum: 3, maximum: 10 }, uniqueness: true, format: { with: VALID_TENANT_REGEX }

  # @!attribute title
  #   @return [String] the tenant's title
  validates :title, length: { minimum: 5, maximum: 100 }, uniqueness: true

  # @!attribute state
  #   @return ['standard', 'default'] the tenant's status.
  #     - 'default' --- tenant is marked as default (only one tenant may be default)
  #     - 'standard' --- tenant is marked as standard
  enum state: { standard: 0, default: 1 }

  has_many :tenant_systems, class_name: 'Anoubis::Tenant::TenantSystem'

  ##
  # Is called before validation when new tenant is being created. If it's a first tenant then it sets {#ident}
  # value to 'sys'
  def before_validation_tenant_create
    if self.id
      if self.id == 1
        self.ident = 'sys'
        return true
      end
    end
  end

  ##
  # Is called before validation when tenant is being updated. Prevents the changing {#ident} value.
  def before_validation_tenant_update
    if self.id == 1 && self.ident != self.ident_was
      errors.add(:ident, I18n.t('anubis.tenants.errors.cant_change_ident'))
      throw(:abort, __method__)
    end
  end

  ##
  # Is called after new tenant was created. Adds access for this tenant to main system with id 1.
  def after_create_tenant
    Anoubis::Tenant::TenantSystem.find_or_create_by(tenant_id: self.id, system_id: 1) if self.id != 1
  end

  ##
  # Is called after tenant had been updated. If {#ident} value had been changed then procedure updates
  # every {Anoubis::User#login} value.
  # Also if current tenant {#state} value had been set as 'default', then procedure sets {#state}
  # value of all other tenants as 'standard'.
  def after_update_tenant
    if self.ident_was != self.ident
      self.update_users_login self.id, self.ident
    end

    # If current tenant had been set as 'default', then sets all other tenants as 'standard'.
    if self.state != self.state_was && self.state = 'default'
      Anoubis::Tenant::Tenant.where(state: Anoubis::Tenant::Tenant.states[:default]).update_all(state: Anoubis::Tenant::Tenant.states[:standard])
    end
  end

  ##
  # Is called before tenant will be stored in database. Changes {#ident} value to lower case.
  def before_save_tenant
    self.ident = self.ident.downcase if self.ident
  end

  ##
  # Is called before tenant will be deleted from database. Checks the ability to destroy a tenant.
  def before_destroy_tenant
    if self.id == 1
      errors.add(:base, I18n.t('anubis.tenants.errors.cant_destroy'))
      throw(:abort, __method__)
    end

    if !can_destroy?
      errors.add(:base, I18n.t('anubis.tenants.errors.has_childs'))
      throw(:abort, __method__)
    end
  end

  ##
  # Changes every {User#login} value based on {#ident} value. Procedure makes direct update
  # in database and doesn't call any callbacks of {Anoubis::Tenant::User} model.
  # @param id [Integer] user unique identifier
  # @param ident [String] new tenant identifier
  def update_users_login (id, ident)
    query = <<-SQL
            UPDATE users SET users.login = CONCAT(users.email, '.#{ident}') WHERE users.tenant_id = #{id}
    SQL
    Anoubis::Tenant::User.connection.execute query
  end
end