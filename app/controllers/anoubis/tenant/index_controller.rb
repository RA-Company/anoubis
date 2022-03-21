require_dependency "anoubis/tenant/application_controller"
require_dependency "anoubis/tenant/index/actions"
require_dependency "anoubis/tenant/index/callbacks"

module Anoubis
  ##
  # Module presents all tenant functions for Anubis Library
  module Tenant
    ##
    # Controller processes main system functions. Authenticates user, checks user access, outputs main menu and etc.
    class IndexController < Anoubis::Tenant::ApplicationController
      include Anoubis::Tenant::Index::Actions
      include Anoubis::Tenant::Index::Callbacks

      ##
      # Check if authentication required
      def authenticate?
        if controller_name == 'index'
          if action_name == 'login'
            return false
          end
        end
        return true
      end

      ##
      # Check if authentication required
      def check_menu_access?
        if controller_name == 'index'
          if action_name == 'login' || action_name == 'menu' || action_name == 'logout'
            return false
          end
        end
        return true
      end
    end
  end
end