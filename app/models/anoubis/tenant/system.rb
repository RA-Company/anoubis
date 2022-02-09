##
# System model. Stores information about all portal's systems.
class Anoubis::Tenant::System < Anoubis::Core::ApplicationRecord
  # Redefines default table name
  self.table_name = 'systems'

  before_validation :before_validation_system_create, on: :create
  before_validation :before_validation_system_update, on: :update
  after_create :after_create_system
  before_save :before_save_system
  after_update :after_update_system
  before_destroy :before_destroy_system

  # System's identifier consists of lowercase alphabetic symbols.
  VALID_SYSTEM_REGEX = /[a-z]\z/i

  # @!attribute ident
  #   @return [String] the system's identifier. Identifier consists of lowercase alphabetical symbols.
  validates :ident, length: { minimum: 3, maximum: 15 }, uniqueness: true, format: { with: VALID_SYSTEM_REGEX }

  has_many :tenant_systems, class_name: 'Anoubis::Tenant::TenantSystem'
  has_many :groups, class_name: 'Anoubis::Tenant::Group'
  has_many :system_menus, class_name: 'Anoubis::Tenant::SystemMenu'
  has_many :system_locales, class_name: 'Anoubis::Tenant::SystemLocale'

  ##
  # Is called before validation when new system is being created. If it's a first system then it sets {#ident}
  # value to 'sys'
  def before_validation_system_create
    if self.id
      if self.id == 1
        self.ident = 'sys'
        return true
      end
    end
  end

  ##
  # Is called before validation when system is being updated. Prevents the changing {#ident} value for
  # system with id 1.
  def before_validation_system_update
    if self.id == 1 && self.ident_was != self.ident
      errors.add(:ident, I18n.t('anubis.systems.errors.cant_change_ident'))
      throw(:abort, __method__)
    end
  end

  ##
  # Is called after new system was created. Creates administration group for new system.
  def after_create_system
    if self.id == 1
      data = Anoubis::Tenant::Group.create(id: 1)
      I18n.available_locales.each do |locale|
        I18n.locale = locale
        Anoubis::Tenant::GroupLocale.find_or_create_by(group_id: data.id, locale: Anoubis::Tenant::MenuLocale.locales[locale.to_s.to_sym]) do |system_locale|
          system_locale.title = I18n.t('anubis.install.admins_group')
        end
      end
    else
      data = Anoubis::Tenant::Group.find_or_create_by(ident: 'admin', system_id: self.id)
      I18n.available_locales.each do |locale|
        I18n.locale = locale
        Anoubis::Tenant::GroupLocale.find_or_create_by(group_id: data.id, locale: Anoubis::Tenant::MenuLocale.locales[locale.to_s.to_sym]) do |system_locale|
          system_locale.title = I18n.t('anubis.install.admins_group')
        end
      end
    end
  end

  ##
  # Is called before system will be stored in database. Changes {#ident} value to lower case.
  def before_save_system
    self.ident = self.ident.downcase if self.ident
  end

  ##
  # Is called after system had been updated. If {#ident} value had been changed then procedure updates
  # every {Anoubis::Group#full_ident} value.
  def after_update_system
    if self.ident_was != self.ident
      update_groups_full_ident self.id, self.ident
    end
  end

  ##
  # Is called before system will be deleted from database. Checks the ability to destroy a system. Delete
  # all translations for system model from {GroupLocale}.
  def before_destroy_system
    if self.id == 1
      errors.add(:base, I18n.t('anubis.tenants.errors.cant_destroy'))
      throw(:abort, __method__)
    end

    Anoubis::Tenant::SystemLocale.where(system_id: self.id).each do |system_locale|
      system_locale.destroy
    end

    if !can_destroy?
      errors.add(:base, I18n.t('anubis.tenants.errors.has_childs'))
      throw(:abort, __method__)
    end
  end

  ##
  # Updates {Group#full_ident} when changed system's identifier.
  # @param id [Integer] group unique identifier
  # @param ident [String] new system identifier
  def update_groups_full_ident (id, ident)
    query = <<-SQL
            UPDATE groups SET groups.full_ident = CONCAT('#{ident}.', groups.ident) WHERE groups.system_id = #{id}
    SQL
    Anoubis::Tenant::Group.connection.execute query
  end

  ##
  # Returns model localization data from {SystemLocale}.
  # @return [SystemLocale] localization for current system
  def model_locale
    @model_locale ||= self.system_locales.where(locale: Anoubis::Tenant::SystemLocale.locales[self.current_locale.to_sym]).first
  end

  # @!attribute title
  # @return [String] the system's title. Title loads from {SystemLocale#title} based on {#current_locale}
  def title
    self.model_locale.title if self.model_locale
  end
end