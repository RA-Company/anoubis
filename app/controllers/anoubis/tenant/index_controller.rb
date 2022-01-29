require_dependency "anubis/tenant/application_controller"
require_dependency "anubis/tenant/index/actions"
require_dependency "anubis/tenant/index/callbacks"

module Anubis
  ##
  # Module presents all tenant functions for Anubis Library
  module Tenant
    ##
    # Controller processes main system functions. Authenticates user, checks user access, outputs main menu and etc.
    class IndexController < Anubis::Tenant::ApplicationController
      include Anubis::Tenant::Index::Actions
      include Anubis::Tenant::Index::Callbacks

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