module Anoubis
  module Output
    ##
    # Output subclass that represents data for frame action
    class Frame < Basic
      # @!attribute [rw] short
      #   @return [string] the short title of current loaded frame.
      class_attribute :short

      # @!attribute [rw] mode
      #   @return [string] the identificator for current frame.
      class_attribute :mode

      # @!attribute [rw] access
      #   @return [String] the access to the menu element for current user ('read', 'write').
      class_attribute :access

      # @!attribute [rw] tab_items
      #   @return [Array] the array of tab elements {Anoubis::Output::TabItem}.
      class_attribute :tab_items

      # @!attribute [rw] tabs
      #   @return [Hash] the hash of menu elements {Anoubis::Output::TabItem} with 'mode' as a key.
      class_attribute :tabs

      ##
      # Initializes menu output data. Generates default values.
      def initialize
        super
        self.title = ''
        self.short = ''
        self.mode = ''
        self.access = 'read'
        self.tab_items = []
        self.tabs = {}
      end

      ##
      # Adds new tab into tabs hash
      # @param [Hash] options the tab element options
      # @option options [String] :key The identifier of the tab element.
      # @option options [String] :title The title of the tab element.
      # @option options [String] :hint The hint for the tab element.
      def addTab(options)
        tab = TabItem.new options
        self.tab_items.push tab
        self.tabs[tab.tab.to_s.to_sym] = self.tab_items[self.tab_items.count-1]
      end

      ##
      # Generates hash representation of output class
      # @return [Hash] hash representation of all data
      def to_h
        result = super.to_h
        return result if self.result != 0
        result[:short] = self.short
        result[:mode] = self.mode
        result[:access] = self.access
        result[:tabs] = []
        self.tab_items.each { |item|
          result[:tabs].push(item.to_h) if item
        }
        result
      end
    end

    ##
    # Subclass of tab element.
    class TabItem
      # @!attribute [rw] tab
      #   @return [string] the tab identificator.
      class_attribute :tab

      # @!attribute [rw] title
      #   @return [string] the tab title.
      class_attribute :title

      # @!attribute [rw] hint
      #   @return [string] the tab hint (value may not be present).
      class_attribute :hint

      # @!attribute [rw] button_items
      #   @return [Array] the array of tab elements {Anoubis::Output::FrameButtonItem}.
      class_attribute :button_items

      # @!attribute [rw] buttons
      #   @return [Hash] the hash of menu elements {Anoubis::Output::FrameButtonItem} with 'key' as a key.
      class_attribute :buttons

      # @!attribute [rw] filter
      #   @return [Boolean] sets into true when tab has filter button
      class_attribute :filter

      # @!attribute [rw] export
      #   @return [Boolean] sets into true when tab has export button
      class_attribute :export

      ##
      # Initializes tab element data. Generates default values.
      def initialize(options = {})
        if options.has_key? :tab
          self.tab = options[:tab].to_s
        else
          self.tab = ''
        end

        if options.has_key? :title
          self.title = options[:title]
        else
          self.title = ''
        end

        if options.has_key? :hint
          self.hint = options[:hint]
        else
          self.hint = ''
        end

        if options.has_key? :filter
          self.filter = options[:filter]
        else
          self.filter = true
        end

        if options.has_key? :export
          self.export = options[:export]
        else
          self.export = true
        end

        self.button_items = []
        self.buttons = {}

        if options.has_key? :buttons
          options[:buttons].each do |key, button|
            button[:key] = key.to_s
            self.addButton(button)
          end
        end
      end

      ##
      # Adds new button into frame buttons hash hash
      # @param [Hash] options the button element options
      # @option options [String] :key The identifier of the button element.
      # @option options [String] :type The type of the button ('primary', 'danger', 'default')
      # @option options [String] :mode The button action object ('single', 'multiple')
      def addButton(options)
        button = FrameButtonItem.new options
        self.button_items.push button
        self.buttons[button.key.to_s.to_sym] = self.button_items[self.button_items.count-1]
      end

      ##
      # Generates hash representation of output class
      # @return [Hash] hash representation of all data
      def to_h
        result = {
            tab: self.tab,
            title: self.title,
            buttons: [],
            filter: self.filter,
            export: self.export
        }
        result[:hint] = self.hint if self.hint != ''
        self.button_items.each { |item|
          result[:buttons].push(item.to_h) if item
        }
        result
      end
    end

    ##
    # Subclass of frame button element.
    class FrameButtonItem
      # @!attribute [rw] key
      #   @return [string] the button identificator.
      class_attribute :key

      # @!attribute [rw] title
      #   @return [string] the button title.
      class_attribute :title

      # @!attribute [rw] hint
      #   @return [string] the button hint.
      class_attribute :hint

      # @!attribute [rw] mode
      #   @return [string] the button action object ('single', 'multiple')
      class_attribute :mode, default: 'single'

      # @!attribute [rw] type
      #   @return [string] the type of the button ('primary', 'danger', 'default')
      class_attribute :type, default: 'default'

      # @!attribute [rw] decorate
      #   @return [string] button decoration ('none', 'space')
      class_attribute :decoration, default: 'none'

      ##
      # Initializes button element data. Generates default values.
      def initialize(options = {})
        self.key = options.key?(:key) ? options[:key].to_s : ''
        self.type = options.key?(:type) ? options[:type].to_s : 'default'
        self.mode = options.key?(:mode) ? options[:mode].to_s : 'single'
        self.title = options.key?(:title) ? options[:title].to_s : ''
        self.hint = options.key?(:hint) ? options[:hint].to_s : ''
        self.decoration = options.key?(:decoration) ? options[:decoration] : 'none'
      end

      ##
      # Generates hash representation of output class
      # @return [Hash] hash representation of all data
      def to_h
        result = {
          key: self.key,
          mode: self.mode,
          type: self.type,
          decoration: self.decoration
        }
        result[:title] = self.title if self.title != ''
        result[:hint] = self.hint if self.hint != ''
        result
      end
    end
  end
end