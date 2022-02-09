##
# Menu model. Stores information about all menu elements of the portal. Menu model defines the dependence
# between controller and user access.
class Anoubis::Tenant::Menu < ApplicationRecord
  # Redefines default table name
  self.table_name = 'menus'

  before_create :before_create_menu
  before_update :before_update_menu
  before_save :before_save_menu
  before_destroy :before_destroy_menu
  after_destroy :after_destroy_menu

  # @!attribute mode
  #   @return [String] the controller path for menu element.
  validates :mode, presence: true, uniqueness: true

  # @!attribute action
  #   @return [String] the default action of menu element ('data', 'menu', etc.).
  validates :action, presence: true

  # @!attribute tab
  #   @return [Integer] the nesting level of menu element
  validates :tab, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # @!attribute position
  #   @return [Integer] the order position of menu element in current level.
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # @!attribute page_size
  #   @return [Integer] the default page size for table of data frame.
  validates :page_size, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # @!attribute menu
  #   @return [Menu, nil] the parent menu for element menu (if exists).
  belongs_to :menu, class_name: 'Anoubis::Tenant::Menu', optional: true
  has_many :menus, class_name: 'Anoubis::Tenant::Menu'

  has_many :group_menus, class_name: 'Anoubis::Tenant::GroupMenu'
  has_many :system_menus, class_name: 'Anoubis::Tenant::SystemMenu'
  has_many :menu_locales, class_name: 'Anoubis::Tenant::MenuLocale'

  # @!attribute status
  #   @return ['enabled', 'disabled'] the status of menu element.
  #     - 'enabled' --- element is enabled and is used by the system.
  #     - 'disabled' --- element is disabled and isn't used by the system.
  enum status: { enabled: 0, disabled: 1 }

  # @!attribute state
  #   @return ['visible', 'hidden'] the visibility of menu element. Attribute is used in fronted application.
  #     - 'visible' --- element is visible.
  #     - 'hidden' --- element is hidden.
  enum state: { visible: 0, hidden: 1 }

  ##
  # Is called before menu will be created in database. Sets {#position} as last {#position} + 1 on current {#tab}.
  # After this calls {#before_update_menu} for additional modification.
  def before_create_menu
    data = Anoubis::Tenant::Menu.where(menu_id: self.menu_id).maximum(:position)
    self.position = if data then data + 1 else 0 end

    self.before_update_menu
  end

  ##
  # Is called before menu will be stored in database. Sets {#mode} and {#action} in lowercase. If {#page_size}
  # doesn't defined then sets it to 20. If defined parent menu element then sets {#tab} based on {#tab} of
  # parent menu element + 1.
  def before_update_menu
    self.mode = mode.downcase
    self.action = self.action.downcase
    self.page_size = 20 if !self.page_size
    self.page_size = self.page_size.to_i

    parent_menu = Anoubis::Tenant::Menu.where(id: self.menu_id).first
    if parent_menu
      self.tab = parent_menu.tab + 1
    else
      self.tab = 0
    end
  end

  ##
  # Is called right before menu will be stored in database (after {#before_create_menu} and {#before_update_menu}).
  # Deletes cache data for this menu in Redis database.
  def before_save_menu
    self.redis.del(self.redis_prefix + 'menu_' + self.mode) if self.redis
  end

  ##
  # Is called before menu will be deleted from database. Checks the ability to destroy a menu. Delete
  # all translations for menu model from {MenuLocale}.
  def before_destroy_menu
    Anoubis::Tenant::MenuLocale.where(menu_id: self.id).each do |menu_locale|
      menu_locale.destroy
    end

    if !can_destroy?
      errors.add(:base, I18n.t('anubis.menus.errors.has_childs'))
      throw(:abort, __method__)
    end
    #childs = !self.menus.empty?
    #childs = !self.group_menus.empty? if !childs
    #childs = !self.system_menus.empty? if !childs

    #return if !childs

    #errors.add(:base, I18n.t('menus.errors.has_childs'))
    #throw(:abort, __method__)
  end

  ##
  # Is called after menu was deleted from database. Procedure recalculates position of other menu elements.
  def after_destroy_menu
    query = <<-SQL
            UPDATE menus
            SET menus.position = menus.position - 1
            WHERE menus.tab = #{self.tab} AND menus.position > #{self.position}
    SQL
    Anoubis::Tenant::Menu.connection.execute query
    #i = self.position
    #Anoubis::Tenant::Menu.where(menu_id: self.menu_id, position: (self.position+1..Float::INFINITY)).find_each do |menu|
    #        menu.position = i
    #        menu.save
    #        i += 1
    #      end
    Anoubis::Tenant::Menu.where(menu_id: self.id).find_each do |menu|
      menu.destroy
    end
  end

  ##
  # Returns model localization data from {MenuLocale}.
  # @return [MenuLocale] localization for current menu
  def model_locale
    @model_locale ||= self.menu_locales.where(locale: Anoubis::Tenant::MenuLocale.locales[self.current_locale.to_sym]).first
  end

  # @!attribute title
  # @return [String] the menu's title. Title loads from {MenuLocale#title} based on {#current_locale}
  def title
    self.model_locale.title if self.model_locale
  end

  # @!attribute page_title
  # @return [String] the menu's page title. Page title loads from {MenuLocale#page_title} based on {#current_locale}
  def page_title
    self.model_locale.page_title if self.model_locale
  end

  # @!attribute short_title
  # @return [String] the menu's short title. Short title loads from {MenuLocale#short_title} based on {#current_locale}
  def short_title
    self.model_locale.short_title if self.model_locale
  end
end