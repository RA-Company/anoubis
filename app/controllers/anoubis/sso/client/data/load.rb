##
# Module loads data from external sources for {Anubis::Sso::Client::DataController}
module Anubis::Sso::Client::Data::Load
  include Anubis::Core::Data::Load

  def load_menu_data
    menu_json = self.redis.get(self.redis_prefix + 'menu:' + params[:controller])

    unless menu_json
      menu = Anubis::Sso::Client::Menu.where(mode: params[:controller], status: 'enabled').first
      self.redis.set(self.redis_prefix + 'menu:'+ params[:controller], menu.to_json) if menu
    else
      menu = Anubis::Sso::Client::Menu.new(JSON.parse(menu_json,  { :symbolize_names => true }))
    end

    if menu
      self.etc.menu = Anubis::Etc::Menu.new menu

      if self.writer
        self.etc.menu.access = 'write'
      else
        self.etc.menu.access = 'read'
      end
    end
  end
end