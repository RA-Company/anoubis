module Anubis
  module Output
    ##
    # Output subclass that represents data for edit(new) action
    class Edit < Basic
      # @!attribute [rw]
      # @return [String] the title of edit data
      class_attribute :title

      # @!attribute [rw] fields
      #   @return [Array] array of output fields
      class_attribute :fields

      # @!attribute [rw]
      # @return [Hash] the hash of defined fields.
      class_attribute :values, default: {}

      # @!attribute [rw]
      # @return [Hash] the hash of additional field options.
      class_attribute :options, default: {}

      # @!attribute [rw]
      # @return [String] additional action after update
      class_attribute :action


      ##
      # Initializes menu output data. Generates default values.
      def initialize
        super
        self.title = ''
        self.fields = nil
        self.values = {}
        self.options = {}
        self.action = ''
      end

      ##
      # Generates hash representation of output class
      # @return [Hash] hash representation of all data
      def to_h
        result = super.to_h
        return result if self.result != 0
        result[:title] = self.title if self.title != ''
        result[:fields] = self.fields if self.fields
        result[:action] = self.action if self.action != ''
        result.merge!({
                          values: self.values,
                          options: self.options_to_json(self.options)
                      })
        result
      end
    end
  end
end