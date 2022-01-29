module Anubis
  module Etc
    ##
    # Definitions of fields order.
    class FieldOrder
      # @!attribute [rw]
      # Returns order field (or array of fields)
      # @return [String, Array, Symbol] field or field list.
      class_attribute :field, default: nil

      # @!attribute [rw]
      # Field default order.
      # @return [Symbol] default order
      class_attribute :order, default: :asc

      # @!attribute [rw]
      # Defines if this field order by default.
      # @return [Boolean] Defines if this field order by default
      class_attribute :default, default: false

      ##
      # Sets default parameters for field order
      # @param [Hash] options initial model options
      # @option options [String, Array, Symbol] :field describes field or fields name for order
      # @option options [Symbol] :order default order type (:asc or :desc)
      # @option options [Boolean] :default if this field default in order list
      def initialize(options = {})
        self.default = false
        if options.key? :default
          self.default = true if options[:default].class == TrueClass
        end
        self.order = :asc
        if options.key? :order
          self.order = :desc if options[:order] == :desc || options[:order].to_s.downcase == 'desc'
        end
        self.field = if options.key? :field then options[:field] else nil end
      end

      ##
      # Generates hash representation of all class parameters,
      # @return [Hash] hash representation of all data
      def to_h
        {
            field: self.field,
            order: self.order,
            default: self.default
        }
      end
    end
  end
end