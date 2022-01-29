module Anubis
  module Etc
    ##
    # Definitions of tab options.
    class TabItem
      # @!attribute [rw]
      # Returns tab identifier
      # @return [String] tab's identifier.
      class_attribute :tab, default: nil

      # @!attribute [rw]
      # Returns tab title
      # @return [String] tab's title.
      class_attribute :title, default: ''

      # @!attribute [rw]
      # Returns tab hint
      # @return [String] tab's hint.
      class_attribute :hint, default: ''

      # @!attribute [rw]
      # Returns tab where for selection from model.
      # @return [Hash|Array] tab's where
      class_attribute :where, default: []

      # @!attribute [rw]
      # Returns possibility for export data for this tab <i>(default: true)</i>
      # @return [Boolean] tab's export possibility
      class_attribute :export, default: true

      # @!attribute [rw]
      # Returns possibility for filter data for this tab <i>(default: true)</i>
      # @return [Boolean] tab's filter possibility
      class_attribute :filter, default: true

      # @!attribute [rw]
      # Returns possibility for filter data for this tab <i>(default: true)</i>
      # @return [Hash] tab's filter possibility
      class_attribute :buttons, default: {}

      # @!attribute [rw]
      # Returns order field for this tab <i>(default: nil)</i>
      # @return [String] tab's order field
      class_attribute :sort, default: nil

      # @!attribute [rw]
      # Returns order type for this tab ('asc' or 'desc') <i>(default: nil)</i>
      # @return [String] tab's order type
      class_attribute :order, default: nil

      ##
      # Sets default parameters for tab
      # @param options [String] initial tab options
      # @option options [String] :tab tab identifier
      def initialize(options = {})
        self.tab = if options.key?(:tab) then options[:tab] else nil end
        self.sort = if options.key?(:sort) then options[:sort] else nil end
        self.order = ''
        if options.key? :order
          self.order = options[:order] if %w[asc desc].include?(options[:order])
        end
        self.title = if options.key?(:title) then options[:title] else self.tab.humanize end
        self.hint = if options.key?(:hint) then options[:hint] else '' end
        self.where = if options.key?(:where) then options[:where] else [] end
        self.export = if options.key?(:export) then options[:export] else true end
        self.filter = if options.key?(:filter) then options[:filter] else true end
        self.buttons = if options.key?(:buttons) then options[:buttons] else true end
      end

      ##
      # Generates hash representation of all class parameters,
      # @return [Hash] hash representation of all parameters
      def to_h
        result = {
            tab: self.tab,
            title: self.title,
            hint: self.hint,
            where: self.where,
            export: self.export,
            filter: self.filter,
            buttons: self.buttons
        }
        if self.sort
          result[:sort] = self.sort
          result[:order] = self.order if self.order != ''
        end
        result
      end
    end
  end
end