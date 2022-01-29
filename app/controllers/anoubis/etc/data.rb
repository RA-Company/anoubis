module Anubis
  module Etc
    ##
    # Class stores data information for current controller
    class Data
      # @!attribute [rw] data
      #   @return [ActiveRecord, nil] current loaded data from the defined model or nil if data not loaded.
      #   @note Data is placed in this attribute when loaded from the model by actions 'index', 'edit', 'update', 'create' etc.
      class_attribute :data

      # @!attribute [rw] fields
      #   @return [Hash<Symbol, Field>, nil] current defined hash of model represented fields or nil if fields aren't defined
      #   @note Field's options are placed in this attribute for actions 'index', 'edit', 'update', 'create' etc.
      class_attribute :fields, default: nil

      # @!attribute [rw] actions
      #   @return [Array, nil] current defined string array of table actions.
      class_attribute :actions, default: nil

      #@!attribute [rw] parent
      #   @return [ActiveRecord] <i>(defaults to: nil)</i> Specify the parent ActiveRecord for controller (if exists)
      class_attribute :parent, default: nil

      #@!attribute [rw] model
      #   @return [ActiveRecord] <i>(defaults to: nil)</i> Specify the current ActiveRecord for controller (if exists)
      class_attribute :model, default: nil

      #@!attribute [rw] eager_load
      #   @return [Array] <i>(defaults to: [])</i> Specify the current eager loaded models
      class_attribute :eager_load, default: []

      #@!attribute [rw] limit
      #   @return [Integer] <i>(defaults to: 10)</i> Specify the total number of returned rows
      class_attribute :limit, default: 10

      #@!attribute [rw] offset
      #   @return [Integer] <i>(defaults to: 0)</i> Specify the default offset for rows were returned
      class_attribute :offset, default: 0

      #@!attribute [rw] count
      #   @return [Integer] <i>(defaults to: 0)</i> Specify the count of rows for defined data model
      class_attribute :count, default: 0

      #@!attribute [rw]
      class_attribute :filter, default: nil

      ##
      # Sets default basic system parameters
      def initialize(options = {})
        self.data = nil
        self.fields = nil
        self.actions = nil
        self.parent = nil
        self.model = nil
        self.count = 0
        self.eager_load = []
        self.limit = 10
        self.offset = 0
        self.filter = nil
      end

      def limit=(value)
        value = value.to_s.to_i
        value = 10 if value < 1
        @limit = value
      end

      def offset=(value)
        value = value.to_s.to_i
        value = 0 if value < 0
        value = 0 if value > self.count
        @offset = value
      end

      def to_h
        {
            fields: self.fields,
            model: self.model,
            eager_load: self.eager_load,
            count: self.count,
            limit: self.limit,
            offset: self.offset,
            actions: self.actions,
            parent: self.parent
        }
      end
    end
  end
end