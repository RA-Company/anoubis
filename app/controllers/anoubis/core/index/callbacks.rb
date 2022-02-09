module Anoubis
  module Core
    ##
    # Module contains all procedures and function for {IndexController}. Consists of {Actions} and {Callbacks} module.
    module Index
      ##
      # Module contains all callbacks {IndexController}.
      module Callbacks
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
    end
  end
end
