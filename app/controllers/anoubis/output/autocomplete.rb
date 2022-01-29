module Anubis
  module Output
    ##
    # Output subclass that represents data for edit(new) action
    class Autocomplete < Basic
      # @!attribute [rw]
      # @return [Hash] the hash of defined fields.
      class_attribute :values, default: {}

      ##
      # Initializes menu output data. Generates default values.
      def initialize
        super
        self.values = []
      end

      ##
      # Generates hash representation of output class
      # @return [Hash] hash representation of all data
      def to_h
        result = super.to_h
        return result if self.result != 0
        result.merge!({
                          values: self.values,
                      })
        result
      end
    end
  end
end