module Anoubis
  module Etc
    ##
    # Class stores main menu parameters and variables
    class Menu
      # @!attribute [rw] title
      #   @return [String] returns title of current menu element
      class_attribute :title, default: ''

      # @!attribute [rw] page_title
      #   @return [String] returns page title of current menu element
      class_attribute :page_title, default: ''

      # @!attribute [rw] short_title
      #   @return [String] returns short title of current menu element
      class_attribute :short_title, default: ''

      # @!attribute [rw] mode
      #   @return [String] returns mode of current menu element
      class_attribute :mode, default: ''

      # @!attribute [rw] parent_mode
      #   @return [String] returns mode of parent menu for current menu element
      class_attribute :parent_mode, default: ''

      # @!attribute [rw] menu_id
      #   @return [Integer] returns id of current menu element
      class_attribute :menu_id, default: nil

      # @!attribute [rw] parent_menu_id
      #   @return [Integer] returns id of parent menu for current menu element
      class_attribute :parent_menu_id, default: nil

      # @!attribute [rw] action
      #   @return [String] returns action of current menu element
      class_attribute :action, default: ''

      # @!attribute [rw] tab
      #   @return [Integer] returns level of current menu element
      class_attribute :tab, default: 0

      # @!attribute [rw] position
      #   @return [Integer] returns position in level of current menu element
      class_attribute :position, default: 0

      # @!attribute [rw] state
      #   @return [String] returns state of current menu element ('visible', 'hidden')
      class_attribute :state, default: 'visible'

      # @!attribute [rw] access
      #   @return [String] returns access state of current menu element ('read', 'write')
      class_attribute :access, default: 'read'

      ##
      # Sets default parameters for menu element
      # @param [Hash] options initial menu paramters
      # @option options [String] :title menu title
      # @option options [String] :page_title page title
      # @option options [String] :short_title short page title
      # @option options [String] :mode menu mode
      # @option options [String] :parent_mode parent menu mode
      # @option options [Integer] :menu_id id of menu (if <b>id</b> isn't defined)
      # @option options [Integer] :id id of menu (if <b>menu_id</b> isn't defined)
      # @option options [Integer] :parent_menu_id id of parent menu
      # @option options [String] :action menu action
      # @option options [Integer] :tab menu tab index
      # @option options [Integer] :position position in current level
      # @option options [String] :state state of the menu ('visible', 'hidden')
      # @option options [String] :access access state of the menu ('read', 'write')
      def initialize(options = {})
        if options.class == Hash
          self.title = options[:title] if options.has_key? :title
          self.page_title = options[:page_title] if options.has_key? :page_title
          self.short_title = options[:short_title] if options.has_key? :short_title
          self.mode = options[:mode] if options.has_key? :mode
          self.parent_mode = options[:parent_mode] if options.has_key? :parent_mode
          self.menu_id = options[:menu_id] if options.has_key? :menu_id
          self.menu_id = options[:id] if options.has_key? :id
          self.parent_menu_id = options[:parent_menu_id] if options.has_key? :parent_menu_id
          self.action = options[:action] if options.has_key? :action
          self.tab = options[:tab] if options.has_key? :tab
          self.position = options[:position] if options.has_key? :position
          self.state = options[:state] if options.has_key? :state
          self.access = options[:access] if options.has_key? :access
        end
        if options.class == Anoubis::Sso::Client::Menu
          self.title = options.title
          self.page_title = options.page_title
          self.short_title = options.short_title
          self.mode = options.mode
          self.menu_id = options.id
          self.parent_menu_id = options.menu_id
          self.action = options.action
          self.tab = options.tab
          self.position = options.position
          self.state = options.state
        end
      end
    end
  end
end