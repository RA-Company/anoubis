module Anubis
  module Output
    ##
    # Output subclass that represents data for destroy action
    class Delete < Basic
      # @!attribute [rw]
      # @return [Array<String>] hash of errors
      class_attribute :errors, default: []

      # @!attribute [rw]
      # @return [Number] deleted id
      class_attribute :id, default: nil

      ##
      # Initializes menu output data. Generates default values.
      def initialize
        super
        self.id = nil
        self.errors = []
      end

      ##
      # Generates hash representation of output class
      # @return [Hash] hash representation of all data
      def to_h
        result = super.to_h
        result[:id] = self.id if self.id
        result[:errors] = self.errors if self.errors.length > 0
        result
      end

      ##
      # Returns customized message if {#result} code equal -4. Another way returns standard message
      # @return [String] customized message
      def message
        return I18n.t('errors.delete_error') if self.result == -4
        return super
      end
    end
  end
end