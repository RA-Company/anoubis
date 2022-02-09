require_dependency "anubis/core/application_controller"
require_dependency "anubis/core/index/actions"
require_dependency "anubis/core/index/callbacks"

module Anoubis
  module Core
    ##
    # Controller processes main system functions. Authenticates user, checks user access, outputs main menu and etc.
    class IndexController < Anoubis::Core::ApplicationController
      include Anoubis::Core::Index::Actions
      include Anoubis::Core::Index::Callbacks

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
