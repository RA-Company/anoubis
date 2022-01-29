##
# Model links menu and systems. Describes if system has access to menu.
class Anoubis::Tenant::SystemMenu < Anoubis::Core::ApplicationRecord
  # Redefines default table name
  self.table_name = 'system_menus'

  after_create :after_create_system_menu
  after_destroy :after_destroy_system_menu

  # @!attribute system
  #   @return [System] reference to the {System} model
  belongs_to :system, class_name: 'Anoubis::Tenant::System'
  validates :system, presence: true, uniqueness: { scope: [:menu_id] }

  # @!attribute menu
  #   @return [Menu] reference to the {Menu} model
  belongs_to :menu, class_name: 'Anoubis::Tenant::Menu'
  validates :menu, presence: true, uniqueness: { scope: [:system_id] }

  ##
  # Is called after create new link between system and menu. If created element has parent element and
  # link to this parent element doesn't present in database then adds this link too.
  def after_create_system_menu
    if self.menu.menu_id != nil
      Anoubis::Tenant::SystemMenu.find_or_create_by(menu: self.menu.menu, system: self.system)
    end
  end

  ##
  # Is called after link between system and menu was deleted from database. It also deletes all child links.
  def after_destroy_system_menu
    ids = []

    Anoubis::Tenant::Menu.where(menu_id: self.menu_id).each do |data|
      ids.push data.id
    end

    Anoubis::Tenant::SystemMenu.where(menu_id: ids, system_id: self.system_id).each do |data|
      data.destroy
    end

    ids = []
    Anoubis::Tenant::Group.where(system_id: self.system_id).each do |data|
      ids.push data.id
    end

    Anoubis::Tenant::GroupMenu.where(menu_id: self.menu_id, group_id: ids).each do |data|
      data.destroy
    end
  end
end