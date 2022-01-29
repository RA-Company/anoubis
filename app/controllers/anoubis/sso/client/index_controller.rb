require_dependency "anubis/sso/client/index/actions"
require_dependency "anubis/sso/client/index/callbacks"

class Anubis::Sso::Client::IndexController < Anubis::Sso::Client::ApplicationController
  include Anubis::Sso::Client::Index::Actions
  include Anubis::Sso::Client::Index::Callbacks

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