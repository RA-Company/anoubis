module Anoubis
  module Etc
    ##
    # Basic system variables class
    class Base
      # @!attribute [rw]
      # @return [Data, nil] current loaded data or nil if data not loaded.
      # @note In this attribute placed data when loaded from the model by actions 'table', 'edit', 'update', 'create' etc.
      class_attribute :data

      # @!attribute [rw]
      # @return [Menu, nil] menu information for current controller
      # Returns menu information for current controller. By default sets to <i>nil</i>.
      class_attribute :menu, default: nil

      # @!attribute [rw]
      # @return [TabItem, nil] tab information for current controller
      # Returns tab information for current controller. By default sets to <i>nil</i>.
      class_attribute :tab, default: nil

      # @!attribute [rw]
      # @return [String] current controller action.
      # Returns current controller action. By default sets to controller action or ''.
      class_attribute :action, default: ''

      # @!attribute [rw]
      # @return [Number] time of request.
      # Returns time that was requested from client. By default sets to <i>0</i>.
      class_attribute :time, default: 0

      ##
      # Sets default system parameters
      # @param [Hash] options initial class options
      # @option options [ActionController::Parameters] :params initial controller parameters
      def initialize(options = {})
        self.data = nil
        self.menu = nil
        self.tab = nil
        self.action = ''

        if options.key? :params
          self.action = options[:params][:action] if options[:params].key? :action
          if options[:params].key? :time
            self.time = options[:params][:time].to_s.to_i
          else
            self.time = 0
          end
        end
      end
    end
  end
end