module Anubis
  module Output
    ##
    # Output subclass that represents data for update or create action
    class Update < Basic
      # @!attribute [rw]
      # @return [Hash] the hash of defined fields.
      class_attribute :values, default: {}

      # @!attribute [rw]
      # @return [Array<String>] hash of errors
      class_attribute :errors, default: []

      # @!attribute [rw]
      # @return [String] resulting post action
      class_attribute :action, default: ''

      ##
      # Initializes menu output data. Generates default values.
      def initialize
        super
        self.values = {}
        self.errors = []
        self.action = ''
        self.messages[:'-3'] = I18n.t('errors.update_error')
      end

      ##
      # Generates hash representation of output class
      # @return [Hash] hash representation of all data
      def to_h
        result = super.to_h
        result[:errors] = self.errors if self.errors.length > 0
        return result if self.result != 0
        result.merge!({
                          values: self.values,
                          action: self.action
                      })
        result
      end
    end
  end
end