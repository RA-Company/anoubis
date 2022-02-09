class Anoubis::Sso::Client::Menu < Anoubis::Sso::Client::ApplicationRecord
  self.table_name = 'menus'

  before_create :before_create_sso_client_menu
  before_update :before_update_sso_client_menu
  before_save :before_save_sso_client_menu
  before_destroy :before_destroy_sso_client_menu
  after_destroy :after_destroy_sso_client_menu

  VALID_IDENT_REGEX = /\A[a-z_\/0-9]*\z/i

  # @!attribute mode
  #   @return [String] the controller path for menu element.
  validates :mode, length: { minimum: 3, maximum: 100 }, uniqueness: { case_sensitive: false }, format: { with: VALID_IDENT_REGEX }

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
  belongs_to :menu, class_name: 'Anoubis::Sso::Client::Menu', optional: true
  has_many :menus, class_name: 'Anoubis::Sso::Client::Menu'

  # @!attribute title
  #   @return [String] the menu's localized title.
  validates :title, presence: true, length: { maximum: 100 }

  def title
    get_locale_field 'title_locale'
  end

  def title=(value)
    self.set_locale_field 'title_locale', value
  end

  # @!attribute page_title
  #   @return [String] the menu's localized page title. Uses in frontend application.
  validates :page_title,  presence: true, length: { minimum: 3, maximum: 200 }

  def page_title
    get_locale_field 'page_title_locale'
  end

  def page_title=(value)
    self.set_locale_field 'page_title_locale', value
  end

  # @!attribute short_title
  #   @return [String] the menu's localized short title. Uses in frontend application.
  validates :short_title,  length: { maximum: 200 }

  def short_title
    get_locale_field 'short_title_locale'
  end

  def short_title=(value)
    self.set_locale_field 'short_title_locale', value
  end

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

  has_many :group_menus, class_name: 'Anoubis::Sso::Client::GroupMenu'

  ##
  # Is called before menu will be created in database. Sets {#position} as last {#position} + 1 on current {#tab}.
  # After this calls {#before_update_menu} for additional modification.
  def before_create_sso_client_menu
    data = Anoubis::Sso::Client::Menu.where(menu_id: self.menu_id).maximum(:position)
    self.position = if data then data + 1 else 0 end

    self.before_update_sso_client_menu
  end

  ##
  # Is called before menu will be stored in database. Sets {#mode} and {#action} in lowercase. If {#page_size}
  # doesn't defined then sets it to 20. If defined parent menu element then sets {#tab} based on {#tab} of
  # parent menu element + 1.
  def before_update_sso_client_menu
    self.mode = mode.downcase
    self.action = self.action.downcase
    self.page_size = 20 if self.page_size == 0
    self.page_size = self.page_size.to_i

    parent_menu = Anoubis::Sso::Client::Menu.where(id: self.menu_id).first
    if parent_menu
      self.tab = parent_menu.tab + 1
    else
      self.tab = 0
    end
  end

  ##
  # Is called right before menu will be stored in database (after {#before_create_menu} and {#before_update_menu}).
  # Deletes cache data for this menu in Redis database.
  def before_save_sso_client_menu
    self.redis.del(self.redis_prefix + 'menu:' + self.mode) if self.redis
  end

  ##
  # Is called before menu will be deleted from database. Checks the ability to destroy a menu. Delete
  # all translations for menu model from {MenuLocale}.
  def before_destroy_sso_client_menu
    if !self.can_destroy?
      errors.add(:base, I18n.t('anubis.menus.errors.has_childs'))
      throw(:abort, __method__)
    end
  end

  ##
  # Is called after menu was deleted from database. Procedure recalculates position of other menu elements.
  def after_destroy_sso_client_menu
    query = <<-SQL
            UPDATE menus
            SET menus.position = menus.position - 1
            WHERE menus.tab = #{self.tab} AND menus.position > #{self.position}
    SQL
    Anoubis::Sso::Client::Menu.connection.execute query
    Anoubis::Sso::Client::Menu.where(menu_id: self.id).find_each do |menu|
      menu.destroy
    end
  end
end