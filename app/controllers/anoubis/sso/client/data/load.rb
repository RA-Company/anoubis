##
# Module loads data from external sources for {Anoubis::Sso::Client::DataController}
module Anoubis::Sso::Client::Data::Load
  include Anoubis::Core::Data::Load

  def load_menu_data
    menu_json = self.redis.get(self.redis_prefix + 'menu:' + params[:controller])

    unless menu_json
      menu = Anoubis::Sso::Client::Menu.where(mode: params[:controller], status: 'enabled').first
      self.redis.set(self.redis_prefix + 'menu:'+ params[:controller], menu.to_json) if menu
    else
      menu = Anoubis::Sso::Client::Menu.new(JSON.parse(menu_json,  { :symbolize_names => true }))
    end

    if menu
      self.etc.menu = Anoubis::Etc::Menu.new menu

      if self.writer
        self.etc.menu.access = 'write'
      else
        self.etc.menu.access = 'read'
      end
    end
  end
end