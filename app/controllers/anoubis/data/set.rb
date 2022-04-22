module Anoubis
  module Data
    ##
    # Module sets system data for {DataController}
    module Set
      ##
      # Sets parent model according by type. Resulting data placed in {Etc::Data#parent self.etc.data.parent}
      # @param action [String] type of used action in controller.
      #   - 'index' - for index action
      #   - 'new' - for new action
      #   - 'create' - for create action
      #   - 'edit' - for edit action
      #   - 'update' - for update action
      #   - 'destroy' - for defstroy action
      def set_parent_model(action = '')
        self.etc.data = Anoubis::Etc::Data.new if !self.etc.data
        self.etc.action = action if action != ''
        self.set_current_tab
      end

      ##
      # Gets tab for current controller and place it into {Etc::Base#tab self.etc.tab} system variable.
      # If params[:tab] absent or incorrect then {Etc::Base#tab self.etc.tab} is set as first value of {Data::Defaults#tabs} hash.
      def set_current_tab
        if !self.etc.tab
          tabs = self.tabs
          if params.key? :tab
            if params[:tab].to_s != ''
              if tabs.key? params[:tab].to_s.to_sym
                self.etc.tab = Etc::TabItem.new(self.get_tab(params[:tab].to_s, tabs[params[:tab].to_s.to_sym]))
              end
            end
          end
          self.etc.tab = Etc::TabItem.new(self.get_tab(tabs.keys[0].to_s, tabs.values[0])) if !self.etc.tab
        end
      end

      ##
      # Defines new action and clears defined for old action variables
      # @param action [String] type of used action in controller.
      def set_new_action(action)
        self.etc.action = action
        self.etc.data.model = nil
      end
    end
  end
end
