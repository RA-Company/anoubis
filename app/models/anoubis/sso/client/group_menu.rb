##
# Model links {Menu} and {Group}. Describes group access to menu.
class Anoubis::Sso::Client::GroupMenu < Anoubis::Sso::Client::ApplicationRecord
  # Redefines default table name
  self.table_name = 'group_menus'

  before_validation :before_validation_sso_client_group_menu
  after_create :after_create_sso_client_group_menu
  before_update :before_update_sso_client_group_menu
  after_destroy :after_destroy_sso_client_group_menu


  # @!attribute group
  #   @return [Group] reference to the {Group} model
  belongs_to :group, :class_name => 'Anoubis::Sso::Client::Group'
  validates :group, presence: true, uniqueness: { scope: [:menu_id] }

  # @!attribute menu
  #   @return [Menu] reference to the {Menu} model
  belongs_to :menu, :class_name => 'Anoubis::Sso::Client::Menu'
  validates :menu, presence: true, uniqueness: { scope: [:group_id] }

  # @!attribute access
  #   @return ['not', 'read', 'write', 'disable'] group access to menu element.
  #     - 'not' --- menu element doesn't available for this group
  #     - 'read' --- group has access to menu element only for read data
  #     - 'write' --- group has access to menu element for read and write data
  #     - 'disable' --- group hasn't access to menu element
  enum access: { not: 0, read: 20, write: 40, disable: 60 }

  ##
  # Is called before validation when the link between menu and group is being created or updated.
  # Procedure checks if group belongs a system that has access to this menu element. If {#access} doesn't
  # defined then {#access} sets to 'read'
  def before_validation_sso_client_group_menu
    self.access = 'read' if !self.access
  end

  ##
  # Is called after new link between menu and group was created. If new element has parent with link that
  # doesn't present in database then adds this link to database with {#access} defined as 'read'.
  def after_create_sso_client_group_menu
    if self.menu.menu_id != nil
      Anoubis::Sso::Client::GroupMenu.find_or_create_by(menu_id: self.menu.menu_id, group_id: self.group_id) do |menu|
        menu.access = 'read'
      end
    end
    self.after_modify_sso_client_group_menu
  end

  ##
  # Is called before link between menu and group will be updated. Procedure prevents changing {#menu}
  # and {#group} value.
  def before_update_sso_client_group_menu
    self.menu_id = self.menu_id_was if self.menu_id_changed?
    self.group_id = self.group_id_was if self.group_id_changed?
    self.after_modify_sso_client_group_menu
  end

  ##
  # Is called after link between menu and group had been deleted from database. It also deletes all child links.
  def after_destroy_sso_client_group_menu
    Anoubis::Sso::Client::Menu.select(:id).where(menu_id: self.menu_id).each do |menu|
      Anoubis::Sso::Client::GroupMenu.where(menu_id: menu.id, group_id: self.group_id).each do |group_menu|
        group_menu.destroy
      end
    end
    self.after_modify_sso_client_group_menu
  end

  ##
  # Deletes all user's keys that belong this menu element in Redis database.
  def after_modify_sso_client_group_menu
    if self.redis
      self.redis.keys(self.redis_prefix + '*_' + self.menu.mode).each do |data|
        self.redis.del data
      end
    end
  end

  def title
    self.get_localized_menu 'title'
  end

  def page_title
    self.get_localized_menu 'page_title'
  end

  def short_title
    self.get_localized_menu 'short_title'
  end

  def get_localized_menu(field)
    loc_field = (field.to_s + '_locale').to_sym
    begin
      self[loc_field] = JSON.parse(self[loc_field]) if self[loc_field]
    rescue

    end

    begin
      result = self.get_locale_field loc_field.to_s
    rescue
      result = eval('self.menu.' + field.to_s)
    end

    result
  end
end