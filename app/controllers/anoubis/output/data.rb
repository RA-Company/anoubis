module Anoubis
  module Output
    ##
    # Output subclass that represents data for default index action
    class Data < Basic
      ##
      # Output subclass that represents data for default index action

      # @!attribute [rw] count
      #   @return [String] the model's row count
      class_attribute :count

      # @!attribute [rw] offset
      #   @return [Integer] output offset for rows were returned
      class_attribute :offset

      # @!attribute [rw] limit
      #   @return [Integer] output limit fro returns rows
      class_attribute :limit

      # @!attribute [rw] data
      #   @return [Array] array of output data
      class_attribute :data

      # @!attribute [rw] fields
      #   @return [Array] array of output fields
      class_attribute :fields

      # @!attribute [rw] filter
      #   @return [Array] array of filter fields
      class_attribute :filter

      # @!attribute [rw]
      # @return [String] order filed name
      # Returns order field for current output data.
      class_attribute :sort

      # @!attribute [rw]
      # @return [String] order filed type
      # Returns order type current output data ('asc' or 'desc').
      class_attribute :order

      # @!attribute [rw]
      # @return [String] field name for manual order table or nil if table can't be sorted
      # Returns name for manual table order
      class_attribute :sortable

      ##
      # Initializes output data. Generates default values.
      def initialize
        super
        self.data = nil
        self.fields = nil
        self.filter = nil
        self.count = 0
        self.offset = 0
        self.limit = 20
        self.sort = nil
        self.order = ''
        self.sortable = nil
      end

      ##
      # Generates hash representation of output class
      # @return [Hash] hash representation of all data
      def to_h
        result = super.to_h
        return result if self.result != 0
        result.merge!({
                          count: self.count,
                          offset: self.offset,
                          limit: self.limit
                      })
        if self.sort
          result[:sort] = self.sort
          result[:order] = self.order
        end

        result.merge!({ fields: self.fields}) if self.fields
        result.merge!({ filter: self.filter}) if self.filter
        result.merge!({ data: self.data}) if self.data
        result[:sortable] = self.sortable if self.sortable
        result
      end

      ##
      # Generates output message based on {#result self.result} variable.
      # @return [String] output message
      def message1
        case self.result
        when -1
          return I18n.t('errors.invalid_login_parameters')
        when -2
          return I18n.t('errors.invalid_login_or_password')
        else
          return super
        end
      end
    end
  end
end