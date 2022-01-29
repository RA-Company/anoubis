require_dependency "anubis/core/application_controller"
require_dependency "anubis/core/index/actions"
require_dependency "anubis/core/index/callbacks"

module Anubis
  module Core
    ##
    # Controller processes main system functions. Authenticates user, checks user access, outputs main menu and etc.
    class IndexController < Anubis::Core::ApplicationController
      include Anubis::Core::Index::Actions
      include Anubis::Core::Index::Callbacks

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
