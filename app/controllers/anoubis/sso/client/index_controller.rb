require_dependency "anoubis/sso/client/index/actions"
require_dependency "anoubis/sso/client/index/callbacks"

class Anoubis::Sso::Client::IndexController < Anoubis::Sso::Client::ApplicationController
  include Anoubis::Sso::Client::Index::Actions
  include Anoubis::Sso::Client::Index::Callbacks

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