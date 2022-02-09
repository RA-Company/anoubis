module Anoubis
  module Output
    ##
    # Output subclass that represents data for menu action
    class Menu < Basic
      # @!attribute [rw] items
      #   @return [Array] the array of menu elements {Anoubis::Output::MenuItem}.
      class_attribute :items

      # @!attribute [rw] keys
      #   @return [Hash] the hash of menu elements {Anoubis::Output::MenuItem} with 'mode' as a key.
      class_attribute :keys

      # @!attribute [rw] user
      #   @return [Hash] the hash of user information.
      class_attribute :user

      ##
      # Initializes menu output data. Generates default values.
      def initialize
        super
        self.items = []
        self.keys = {}
        self.user = {}
      end

      ##
      # Adds new element into menu hash
      # @param [Hash] options the menu element options
      # @option options [String] :title The title of the menu element.
      # @option options [String] :page_title The page title of the menu element.
      # @option options [String] :short_title The short title of the menu element.
      # @option options [String] :mode The mode of the menu element.
      # @option options [String] :action The action type of the menu element ('menu', 'data').
      # @option options [Number] :position The position of the menu element in current level.
      # @option options [Number] :tab The level of the menu element.
      # @option options [String] :state The show state of the menu element ('visible', 'hidden').
      # @option options [String] :access The access to the menu element for current user ('read', 'write').
      def addElement(options)
        if options.has_key? :parent
          if !self.keys.has_key? options[:parent].to_s.to_sym
            options[:parent] = nil
          end
        end
        menu = MenuItem.new options
        self.items.push menu
        self.keys[menu.mode.to_s.to_sym] = self.items[self.items.count-1]
      end

      ##
      # Generates hash representation of output class
      # @return [Hash] hash representation of all data
      def to_h
        result = super.to_h
        return result if self.result != 0
        result[:menu] = []
        self.items.each { |item|
          result[:menu].push(item.to_h) if item
        }
        result[:user] = self.user
        result
      end

      ##
      # Generates output message based on {#result self.result} variable.
      # @return [String] output message
      def message
        case self.result
        when 0
          return I18n.t('success')
        else
          return I18n.t('invalid_menu_output')
        end
      end

      ##
      # Returns menu element
      # @param mode [String] the mode of returned menu element
      # @return [MenuItem | nil] menu element or nil if element isn't exists
      def key(mode)
        if self.keys.has_key? mode.to_s.to_sym

          return self.keys[mode.to_s.to_sym]
        else
          return nil
        end
      end
    end

    ##
    # Subclass of menu element.
    class MenuItem
      # @!attribute [rw] mode
      #   @return [String] the mode of the menu element. Identificator represents path of controller.
      class_attribute :mode

      # @!attribute [rw] title
      #   @return [String] the title of the menu element.
      class_attribute :title

      # @!attribute [rw] page_title
      #   @return [String] the page title of the menu element. Uses for show in page title.
      class_attribute :page_title

      # @!attribute [rw] short_title
      #   @return [String] the short title of the menu element. Uses for short menu link.
      class_attribute :short_title

      # @!attribute [rw] position
      #   @return [Number] the position of the menu element in current level.
      class_attribute :position

      # @!attribute [rw] tab
      #   @return [Number] the level of the menu element.
      class_attribute :tab

      # @!attribute [rw] action
      #   @return [String] the action type of the menu element ('menu', 'data').
      class_attribute :action

      # @!attribute [rw] access
      #   @return [String] the access to the menu element for current user ('read', 'write').
      class_attribute :access

      # @!attribute [rw] state
      #   @return [String] the show state of the menu element ('visible', 'hidden').
      class_attribute :state

      # @!attribute [rw] parent
      #   @return [String] the mode of parent menu of the menu element when tab more then 0.
      class_attribute :parent

      ##
      # Initializes menu element data. Generates default values.
      def initialize(options = {})
        if options.has_key? :mode
          self.mode = options[:mode]
        else
          self.mode = ''
        end

        if options.has_key? :title
          self.title = options[:title]
        else
          self.title = ''
        end

        if options.has_key? :page_title
          self.page_title = options[:page_title]
        else
          self.page_title = ''
        end

        if options.has_key? :short_title
          self.short_title = options[:short_title]
        else
          self.short_title = ''
        end

        if options.has_key? :position
          self.position = options[:position]
        else
          self.position = 0
        end

        if options.has_key? :tab
          self.tab = options[:tab]
        else
          self.tab = 0
        end

        if options.has_key? :action
          self.action = options[:action]
        else
          self.action = 'data'
        end

        if options.has_key? :access
          self.access = options[:access]
        else
          self.access = 'read'
        end

        if options.has_key? :state
          self.state = options[:state]
        else
          self.state = 'visible'
        end

        if options.has_key? :parent
          if options[:parent]
            self.parent = options[:parent]
          else
            self.parent = ''
          end
        else
          self.parent = ''
        end
      end

      ##
      # Generates hash representation of output class
      # @return [Hash] hash representation of all data
      def to_h
        {
            mode: self.mode,
            title: self.title,
            page_title: self.page_title,
            short_title: self.short_title,
            position: self.position,
            tab: self.tab,
            action: self.action,
            access: self.access,
            state:self.state,
            parent: self.parent
        }
      end
    end
  end
end