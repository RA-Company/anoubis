module Anubis
  module Etc
    ##
    # Definitions of model options. Class is used for define attached model.
    class Model
      # @!attribute [rw]
      # Defines model class. This field is required.
      # @return [ActiveRecord] model's class.
      class_attribute :model, default: nil

      # @!attribute [rw]
      # Field name is used for defines title when data selected from model.
      # @return [Symbol] field's name
      class_attribute :title, default: :title

      # @!attribute [rw]
      # Field name is used for defines order field when data selected from model. By default uses field daefined as
      # (#title)
      # @return [Boolean] field's name
      class_attribute :order, default: :title

      # @!attribute [rw]
      # Where parameters are used when data selected from model.
      # @return [Hash] hash of where's parameters
      class_attribute :where, default: {}

      # @!attribute [rw]
      # Special select parameters.
      # @return [String] string of special select or nil
      class_attribute :select, default: nil

      # @!attribute [rw]
      # Timestamp of last changes in the model.
      # @return [Number] timestamp of last changes in model.
      class_attribute :updated_at, default: {}

      ##
      # Sets default parameters for field
      # @param [Hash] options initial model options
      # @option options [ActiveRecord] :model model class
      # @option options [Symbol] :title field name is used for receive options titles
      # @option options [Symbol] :order field name is used for order options
      # @option options [Hash] :where where parameters for select data from model
      def initialize(options = {})
        self.model = options[:model]
        self.title = if options.key? :title then options[:title] else :title end
        self.order = if options.key? :order then options[:order] else self.title end
        self.where = if options.key? :where then options[:where] else {} end
        self.select = if options.key? :select then options[:select] else nil end
        self.updated_at = 0
      end

      ##
      # Generates hash representation of all class parameters,
      # @return [Hash] hash representation of all data
      def to_h
        {
            model: self.model,
            title: self.title,
            order: self.order,
            where: self.where,
            updated_at: self.updated_at
        }
      end
    end
  end
end