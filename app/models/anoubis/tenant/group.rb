##
# Group model. Stores information about usser's groups
class Anoubis::Tenant::Group < Anoubis::Core::ApplicationRecord
  # Redefines default table name
  self.table_name = 'groups'

  before_validation :before_validation_group_create, on: :create
  before_validation :before_validation_group_update, on: :update
  before_save :before_save_group
  before_destroy :before_destroy_group

  # Group's identifier consists of lowercase alphabetic symbols.
  VALID_IDENT_REGEX = /[a-z]\z/i

  # @!attribute ident
  #   @return [String] the group's identifier. Identifier consists of lowercase alphabetical symbols.
  validates :ident, length: { minimum: 3, maximum: 50 }, uniqueness: { scope: [:system_id], case_sensitive: false }, format: { with: VALID_IDENT_REGEX }

  # @!attribute full_ident
  #   @return [String] the calculated group's identification. This identification based on {System#ident} and {#ident}

  # @!attribute system
  #   @return [System] reference to system that owns this group
  belongs_to :system, class_name: 'Anoubis::Tenant::System'

  has_many :group_menus, class_name: 'Anoubis::Tenant::GroupMenu'
  has_many :user_groups, class_name: 'Anoubis::Tenant::UserGroup'
  has_many :group_locales, class_name: 'Anoubis::Tenant::GroupLocale'

  ##
  # Is called before validation when new group is being created. Sets {#ident} value as 'admin' and {#system}
  # value to main system with id 1 if this is a first group.
  def before_validation_group_create
    if self.id
      if self.id == 1
        self.ident = 'admin'
        self.system_id = 1
        return true
      end
    end
  end

  ##
  # Is called before validation when group is being updated. Prevents changing {#ident} value when {#ident}
  # value is 'admin'
  def before_validation_group_update
    if self.ident != self.ident_was && self.ident_was == 'admin'
      errors.add(:ident, I18n.t('tims.groups.errors.cant_change_admin_ident'))
      throw(:abort, __method__)
    end
  end

  ##
  # Is called before group will be stored in database. Changes {#ident} value to lower case.
  def before_save_group
    self.full_ident = self.system.ident+'.'+self.ident
  end

  ##
  # Is called before group will be deleted from database. Checks the ability to destroy a group. Prevents deleting
  # group with id 1. Also destroys all associated links to {User} and {Menu}
  def before_destroy_group
    # Can't destroy admin group of main system
    if self.ident == 'admin' && self.system_id == 1
      errors.add(:base, I18n.t('anubis.groups.errors.cant_destroy_admin_group'))
      throw(:abort, __method__)
    end

    Anoubis::Tenant::GroupLocale.where(group_id: self.id).each do |group_locale|
      group_locale.destroy
    end

    unless user_groups.empty?
      errors.add(:base, I18n.t('anubis.groups.errors.cant_destroy_group_with_users'))
      throw(:abort, __method__)
    end

    # Before destroy group delete all associated links to users and menus
    Anoubis::Tenant::GroupMenu.where(group_id: self.id).delete_all
    #Anoubis::Tenant::UserGroup.where(group_id: self.id).delete_all
  end

  ##
  # Returns model localization data from {GroupLocale}.
  # @return [GroupLocale] localization for current group
  def model_locale
    @model_locale ||= self.group_locales.where(locale: Anoubis::Tenant::GroupLocale.locales[self.current_locale.to_sym]).first
  end

  # @!attribute title
  # @return [String] the group's title. Title loads from {GroupLocale#title} based on {#current_locale}
  def title
    self.model_locale.title if self.model_locale
  end
end