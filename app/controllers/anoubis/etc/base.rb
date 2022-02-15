module Anoubis
  module Etc
    ##
    # Basic system variables class
    class Base
      # @!attribute [rw]
      # @return [Data, nil] current loaded data or nil if data not loaded.
      # @note In this attribute placed data when loaded from the model by actions 'table', 'edit', 'update', 'create' etc.
      attr_accessor :data

      # @!attribute [rw]
      # @return [Menu, nil] menu information for current controller
      # Returns menu information for current controller. By default sets to <i>nil</i>.
      attr_accessor :menu

      # @!attribute [rw]
      # @return [TabItem, nil] tab information for current controller
      # Returns tab information for current controller. By default sets to <i>nil</i>.
      attr_accessor :tab

      # @!attribute [rw]
      # @return [String] current controller action.
      # Returns current controller action. By default sets to controller action or ''.
      attr_accessor :action

      # @!attribute [rw]
      # @return [Number] time of request.
      # Returns time that was requested from client. By default sets to <i>0</i>.
      attr_accessor :time

      # @!attribute [rw] version
      # @return [Number] Specifies the api version.
      # Returns API version received from URL. By default sets to <i>0</i>.
      attr_accessor :version

      ##
      # Sets default system parameters
      # @param [Hash] options initial class options
      # @option options [ActionController::Parameters] :params initial controller parameters
      def initialize(options = {})
        self.data = nil
        self.menu = nil
        self.tab = nil
        self.action = ''
        self.time = 0
        self.version = 0


        if options.key? :params
          self.action = options[:params][:action] if options[:params].key? :action
          self.time = options[:params][:time].to_s.to_i if options[:params].key? :time
          self.version = options[:params][:version].to_s.to_i if options[:params].key? :version
        end
      end
    end
  end
end