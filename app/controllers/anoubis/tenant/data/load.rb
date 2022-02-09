module Anoubis
  module Tenant
    module Data
      ##
      # Module loads data from external sources for {DataController}
      module Load
        include Anoubis::Core::Data::Load

        ##
        # Loads current menu data. Procedure loads menu data from MySQL database or from Redis cache and places it in
        # self.etc.menu {Anoubis::Etc#menu}
        def load_menu_data
          menu_json = self.redis.get(self.redis_prefix + 'menu_' + params[:controller])
          menu_locale_json = self.redis.get(self.redis_prefix + 'menu_'+params[:controller]+'_'+self.locale)
          if !menu_json || !menu_locale_json
            menu = Anoubis::Tenant::MenuLocale.eager_load(menu: :menu).where(locale: Anoubis::Tenant::MenuLocale.locales[self.locale.to_sym]).where(['menus.mode = ? AND menus.status = 0', params[:controller]]).first
            if menu
              menu_json = {
                mode: menu.menu.mode,
                menu_id: menu.menu_id,
                parent_menu_id: menu.menu.menu_id,
                action: menu.menu.action,
                tab: menu.menu.tab,
                position: menu.menu.position,
                state: menu.menu.state
              }
              if menu.menu.menu
                menu_json[:parent_mode] = menu.menu.menu.mode
              end
              menu_json = menu_json.to_json
              self.redis.set(self.redis_prefix + 'menu_'+params[:controller], menu_json)
              menu_locale_json = {
                title: menu.title,
                page_title: menu.page_title,
                short_title: menu.short_title
              }.to_json
              self.redis.set(self.redis_prefix + 'menu_'+params[:controller]+'_'+self.locale, menu_locale_json)
            end
          end
          if menu_json && menu_locale_json
            self.etc.menu = Anoubis::Etc::Menu.new JSON.parse(menu_json, {:symbolize_names => true}).merge(JSON.parse(menu_locale_json, {:symbolize_names => true}))
            if self.writer
              self.etc.menu.access = 'write'
            else
              self.etc.menu.access = 'read'
            end
          end
        end
      end
    end
  end
end