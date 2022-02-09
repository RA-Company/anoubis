module Anoubis
  module Etc
    ##
    # Definitions of fields options list for 'checkbox' and 'listbox' type.
    class FieldOptions
      # @!attribute [rw]
      # Describes when options shown in output for 'edit' and 'new' actions. Possible values of fields are:
      # - 'init' -- Options shown only when time set to 0 in action
      # - 'never' -- Options newer shown
      # - 'always' -- Options always shown
      # - 'update' -- Options shown when time less then updated_at time of options model
      # @return [String] options' show type.
      class_attribute :show, default: 'init'

      # @!attribute [rw]
      # Options list.
      # @return [Hash<Symbol, Sring>] options list
      class_attribute :list, default: nil

      # @!attribute [rw]
      # Enum list from ActiveRecord. Is defined for correct filtering.
      # @return [Hash<Symbol, Sring>] enum options list
      class_attribute :enum, default: nil

      # @!attribute [rw]
      # Defines selected line. Default nil
      # @return [Hash] presence of select line
      class_attribute :line, default: nil

      # @!attribute [rw]
      # Defines model's description for complex field
      #
      # <b>Options:</b>
      # - <b>:model</b> (ActiveRecord) -- model class
      # - <b>:title</b> (Symbol) -- field name is used for receive options titles <i>(defaults to: :title)</i>
      # - <b>:order</b> (Symbol) -- field name is used for order options <i>(defaults to: :title option)</i>
      # - <b>:select</b> (Symbol) -- special select statement <i>(defaults to: nil)</i>
      # - <b>:where</b> (Hash) -- where parameters for select data from model <i>(defaults to: {})</i>
      # @return [Model] model's description for complex field
      class_attribute :model, default: nil

      ##
      # Sets default parameters for field options
      # @param [Hash] options initial model options
      # @option options [String] :show describes options shoe type
      # @option options [Hash<Symbol, String>] :list options list
      def initialize(options = {})
        if options.key? :show
          self.show = options[:show] if %w[init never always update].include? options[:show]
        end
        self.show = 'init' if !self.show || self.show == 'init'
        self.line = if options.key? :line then options[:line] else nil end
        self.list = if options.key? :list then options[:list] else nil end
        self.enum = if options.key? :enum then options[:enum] else nil end
        self.model = if options.key? :model then Model.new(options[:model]) else nil end
        self.generate_list if !self.list && self.model
      end

      ##
      # Generate options list based on model
      def generate_list
        self.list = {}
        self.model.model.where(self.model.where).order(self.model.order).each do |data|
          proc = format('%s', self.model.title)
          self.list[data.id.to_s.to_sym] = data.send proc
        end
      end

      ##
      # Generates hash representation of all class parameters,
      # @return [Hash] hash representation of all data
      def to_h
        {
            show: self.show,
            enum: self.enum,
            list: self.list
        }
      end

      public :select
    end
  end
end