module Anubis::Sso::Client::Index::Callbacks
  ##
  # Calls before menu output data.
  def before_menu_output

  end

  ##
  # Calls when menu data is being output
  def around_menu_output(data)
    data
  end
end