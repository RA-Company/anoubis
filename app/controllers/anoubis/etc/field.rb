module Anoubis
  module Etc
    ##
    # Definitions of field options for table column or new (edit) form field.
    class Field
      # @!attribute [rw]
      # Defines field title.
      # @return [String] field's title
      class_attribute :title, default: nil

      # @!attribute [rw]
      # Defines field type
      #
      # Possible values of field's type are 'string', 'integer', 'float', 'listbox', 'checkbox', 'longlistbox'
      # and 'datetime'
      # @return [String] field's type.
      class_attribute :type, default: ''

      # Defines date format for field type 'datetime'
      # Possible values of field's format are 'date', 'full', 'datetime', 'month', 'year'.
      # @return [String] field's type.
      class_attribute :format, default: ''

      # Defines precision for field type 'number'
      # Possible values of this field is integer numbers between 0 and 6. If precision is 0 then number is integer.
      # @return [String] field's type.
      class_attribute :precision, default: 0

      # @!attribute [rw]
      # Defines field order options.
      # @return [FieldOrder] field's order options
      class_attribute :order, default: nil

      # @!attribute [rw]
      # Defines field's visibility for table representation data
      # @return [Boolean] field's visibility
      class_attribute :visible, default: true

      # @!attribute [rw]
      # Field's identifier
      # @return [String] field's identifier
      class_attribute :key, default: nil

      # @!attribute [rw] field
      # Field's name is used for access field value in model
      # @return [String] field's name
      class_attribute :field, default: nil

      # @!attribute [rw] table_field
      # Field's name is used for operation with table data (like 'where', 'order' and etc.)
      # @return [String] field's name in the table
      class_attribute :table_field, default: nil

      # @!attribute [rw] error_text
      # Text is shown when system can't access to data with presented {#field} name
      # @return [String] field's error_text
      class_attribute :error_text, default: ''

      # @!attribute [rw]
      # Describes additional field's options for type 'checkbox', 'listbox'.
      # @return [FieldOptions] field's options.
      class_attribute :options, default: nil

      # @!attribute [rw]
      # Describes if this field could return data for {Anoubis::Data::Actions#autocomplete autocomplete} action.
      # @return [Boolean] possibility for return data on autocomplete action.
      #
      # <b>Options:</b>
      # - <b>:limit</b> (Integer) -- maximum number of elements <i>(defaults to: 10)</i>
      # - <b>:count</b> (Integer) -- Minimum symbols count for output <i>(defaults to: 3)</i>
      # @return [Hash] autocomplete definitions for field
      class_attribute :autocomplete, default: false

      # @!attribute [rw]
      # Defines model's description for complex field
      #
      # <b>Options:</b>
      # - <b>:model</b> (ActiveRecord) -- model class
      # - <b>:title</b> (Symbol) -- field name is used for receive options titles <i>(defaults to: :title)</i>
      # - <b>:order</b> (Symbol) -- field name is used for order options <i>(defaults to: :title option)</i>
      # - <b>:where</b> (Hash) -- where parameters for select data from model <i>(defaults to: {})</i>
      # @return [Model] model's description for complex field
      class_attribute :model, default: nil

      # @!attribute [rw] editable
      # Defines if key of this field can be edited
      # @return [String] returns path for edit field options
      class_attribute :editable, default: nil

      ##
      # Sets default parameters for field
      # @param key [Symbol] field's identifier
      # @param model [ActiveRecord] field's model
      # @param options [Hash] field's initial options
      def initialize(key, model, options = {})
        #puts key
        #puts options
        self.field = nil
        self.key = key.to_s
        self.format = ''
        self.precision = 0
        self.title = options[:title] if options.key? :title
        self.type = if options.key? :type then options[:type] else 'string' end
        self.visible = if options.key? :visible then options[:visible] else true end
        self.options = if options.key? :options then FieldOptions.new(options[:options]) else nil end
        if options.key? :order
          if options[:order].class == Hash
            options[:order][:field] = Kernel.format('%s.%s', model.table_name, self.key.to_s) if !options[:order].key? :field
          end
          self.order = if options.key? :order then FieldOrder.new(options[:order]) else nil end
        end
        self.model = if options.key? :model then Model.new(options[:model]) else nil end
        self.editable = if options.key? :editable then options[:editable] else nil end
        self.autocomplete = if options.key? :autocomplete then options[:autocomplete] else nil end
        self.error_text = if options.key? :error_text then options[:error_text] else I18n.t('errors.field_error') end

        self.send Kernel.format('initialize_%s', self.type), options

        if !options.key? :table_field
          if !options.key? :field
            if self.order
              options[:table_field] = self.order.field if self.order.field
            end
          end
        end

        if !self.field
          self.field = if options.key? :field then options[:field] else self.key end
        end

        self.table_field = if options.key?(:table_field) then options[:table_field] else Kernel.format('%s.%s', model.table_name, self.field) end

        if self.autocomplete
          self.autocomplete[:limit] = 10 if !autocomplete.key? :limit
          self.autocomplete[:count] = 3 if !autocomplete.key? :count
          self.autocomplete[:where] = []
        end
        #puts self.to_h
      end

      ##
      # Initialize additional parameters for {Anoubis::Etc::Field#type 'string' field type} for controller actions.
      # @param options [Hash] field's initial options
      def initialize_string (options)

      end

      ##
      # Initialize additional parameters for {Anoubis::Etc::Field#type 'boolean' field type} for controller actions.
      # @param options [Hash] field's initial options
      def initialize_boolean (options)

      end

      ##
      # Initialize additional parameters for {Anoubis::Etc::Field#type 'hash' field type} for controller actions.
      # @param options [Hash] field's initial options
      def initialize_hash (options)

      end

      ##
      # Initialize additional parameters for {Anoubis::Etc::Field#type 'number' field type} for controller actions.
      # @param options [Hash] field's initial options
      def initialize_number (options)
        if options.key? :error_text
          self.error_text = options[:error_text]
        else
          self.error_text = ''
        end
        self.precision = options[:precision].to_s.to_i if options.key? :precision
        self.precision = 0 if self.precision < 0
        self.precision = 16 if self.precision > 16
      end

      ##
      # Initialize additional parameters for {Anoubis::Etc::Field#type 'text' field type} for controller actions.
      # @param options [Hash] field's initial options
      def initialize_text (options)

      end

      ##
      # Initialize additional parameters for {Anoubis::Etc::Field#type 'html' field type} for controller actions.
      # @param options [Hash] field's initial options
      def initialize_html (options)

      end

      ##
      # Initialize additional parameters for {Anoubis::Etc::Field#type 'datetime' field type} for controller actions.
      # @param options [Hash] field's initial options
      def initialize_datetime (options)
        options[:format] = 'datetime' if !options.key? :format
        options[:format] = 'datetime' if !%w[date datetime full year month].include? options[:format]
        self.format = options[:format]
      end

      ##
      # Setups additional parameters for {Anoubis::Etc::Field#type 'listbox' field type} for controller actions.
      # @param options [Hash] field's initial options
      def initialize_listbox (options)
        self.options = FieldOptions.new if !self.options
        if !self.options.list
          if self.model
            if !(%w[update create].include?(options[:action]))
              self.options.show = 'update'
              if self.options.line
                self.options.list = self.options.line
              else
                self.options.list = {}
              end
              self.model.model.select(self.model.select).where(self.model.where).order(self.model.order).each do |dat|
                self.options.list[dat.id.to_s.to_sym] = dat.send(self.model.title)
                if dat.respond_to? :updated_at
                  if self.model.updated_at < dat.updated_at.to_time.utc.to_i
                    self.model.updated_at = dat.updated_at.to_time.utc.to_i
                  end
                end
              end
            end
          end
        end
        options[:format] = 'single' unless options.key? :format
        options[:format] = 'single' unless %w[single multiple].include? options[:format]
        self.format = options[:format]
      end

      ##
      # Initialize additional parameters for {Anoubis::Etc::Field#type 'key' field type} for controller actions.
      # @param options [Hash] field's initial options
      def initialize_key (options)
        if self.model
          self.error_text = '' if options[:action] == 'new'
          self.field = Kernel.format('%s.%s', self.key, self.model.title) if !options.key? :field
          self.table_field = Kernel.format('%s.%s', self.model.model.table_name, self.model.title) if !self.table_field
          self.autocomplete = {} if !options.key? :autocomplete
        end
      end

      ##
      # Return field properties for frontend application
      # @param model [ActiveRecord] field's model
      # @param action [Srting] current field action
      # @return [Hash] field's properties for defined action
      def properties (model, action)
        if %w[new edit].include? action
          return self.properties_forms model, action
        end
        self.properties_index model, action
      end

      ##
      # Return field properties for frontend application for action 'index'
      # @param model [ActiveRecord] field's model
      # @param action [Srting] current field action
      # @return [Hash] field's properties for defined action
      def properties_index (model, action)
        result = {
            id: self.key,
            type: self.type,
            sortable: self.order != nil
        }

        if self.title
          result[:title] = self.title
        else
          result[:title] = model.human_attribute_name(self.key)
        end

        result[:editable] = self.editable if self.editable != nil
        result[:editable] = false if self.type == 'key'
        result[:format] = self.format if self.type == 'datetime'
        result[:precision] = self.precision if self.type == 'number'
        result[:options] = self.hash_to_json(self.options.list) if self.options
        result
      end

      ##
      # Return field properties for frontend application for actions 'edit', 'new'
      # @param model [ActiveRecord] field's model
      # @param action [Srting] current field action
      # @return [Hash] field's properties for defined action
      def properties_forms (model, action)
        mod = model.new
        result = {
            id: self.key,
            title: model.human_attribute_name(self.key),
            type: self.type
        }
        result.merge!(self.send(Kernel.format('properties_forms_%s', self.type), model, action, mod))
        result
      end

      ##
      # Return field properties for frontend application for actions 'edit', 'new' and type 'string'
      # @param model [ActiveRecord] field's model
      # @param action [Srting] current field action
      # @param mod [ActiveRecord] initialized new model element
      # @return [Hash] field's properties for defined action
      def properties_forms_string (model, action, mod)
        result = {}
        errors = {}
        res = model.validators_on(self.key.to_sym).detect { |v| v.is_a?(ActiveModel::Validations::LengthValidator) }
        if res
          if res.options.key? :minimum
            result[:min] = res.options[:minimum]
            errors[:min] = model.human_attribute_name(self.key) + ' ' + mod.errors.generate_message(self.key.to_sym, :too_short, { count: result[:min] })
          end
          if res.options.key? :maximum
            result[:max] = res.options[:maximum]
            errors[:max] = model.human_attribute_name(self.key) + ' ' + mod.errors.generate_message(self.key.to_sym, :too_long, { count: result[:max] })
          end
        end
        res = model.validators_on(self.key.to_sym).detect { |v| v.is_a?(ActiveModel::Validations::PresenceValidator) }
        if res
          result[:required] = true
          errors[:required] = model.human_attribute_name(self.key) + ' ' + mod.errors.generate_message(self.key.to_sym, :blank)
        end
        result[:errors] = errors if errors.length > 0
        result
      end

      ##
      # Return field properties for frontend application for actions 'edit', 'new' and type 'number'
      # @param model [ActiveRecord] field's model
      # @param action [Srting] current field action
      # @param mod [ActiveRecord] initialized new model element
      # @return [Hash] field's properties for defined action
      def properties_forms_number (model, action, mod)
        result = {}
        errors = {}
        res = model.validators_on(self.key.to_sym).detect { |v| v.is_a?(ActiveModel::Validations::NumericalityValidator) }
        if res
          if res.options.key? :greater_than_or_equal_to
            result[:min] = res.options[:greater_than_or_equal_to]
            errors[:min] = model.human_attribute_name(self.key) + ' ' + mod.errors.generate_message(self.key.to_sym, :greater_than_or_equal_to, { count: result[:min] })
          end
          if res.options.key? :maximum
            result[:max] = res.options[:maximum]
            errors[:max] = model.human_attribute_name(self.key) + ' ' + mod.errors.generate_message(self.key.to_sym, :too_long, { count: result[:max] })
          end
        end
        res = model.validators_on(self.key.to_sym).detect { |v| v.is_a?(ActiveModel::Validations::PresenceValidator) }
        if res
          result[:required] = true
          errors[:required] = model.human_attribute_name(self.key) + ' ' + mod.errors.generate_message(self.key.to_sym, :blank)
        end
        result[:errors] = errors if errors.length > 0
        result
      end

      ##
      # Return field properties for frontend application for actions 'edit', 'new' and type 'text'.
      # @param model [ActiveRecord] field's model
      # @param action [Srting] current field action
      # @param mod [ActiveRecord] initialized new model element
      # @return [Hash] field's properties for defined action
      def properties_forms_text (model, action, mod)
        self.properties_forms_string model, action, mod
      end

      ##
      # Return field properties for frontend application for actions 'edit', 'new' and type 'html'.
      # @param model [ActiveRecord] field's model
      # @param action [Srting] current field action
      # @param mod [ActiveRecord] initialized new model element
      # @return [Hash] field's properties for defined action
      def properties_forms_html (model, action, mod)
        self.properties_forms_text model, action, mod
      end

      ##
      # Return field properties for frontend application for actions 'edit', 'new' and type 'listbox'
      # @param model [ActiveRecord] field's model
      # @param action [Srting] current field action
      # @param mod [ActiveRecord] initialized new model element
      # @return [Hash] field's properties for defined action
      def properties_forms_listbox (model, action, mod)
        result = {}
        result[:format] = self.format if self.format == 'multiple'
        result[:options] = self.hash_to_json(self.options.list) if self.options
        result
      end

      ##
      # Return field properties for frontend application for actions 'edit', 'new' and type 'key'
      # @param model [ActiveRecord] field's model
      # @param action [Srting] current field action
      # @param mod [ActiveRecord] initialized new model element
      # @return [Hash] field's properties for defined action
      def properties_forms_key (model, action, mod)
        result = {
            type: 'string',
            autocomplete: true,
            editable: self.editable
        }
        errors = {}
        result[:field] = self.model.title if self.editable
        res = model.validators_on(self.key.to_sym).detect { |v| v.is_a?(ActiveModel::Validations::PresenceValidator) }
        if res
          result[:required] = true
          errors[:required] = model.human_attribute_name(self.key) + ' ' + mod.errors.generate_message(self.key.to_sym, :blank)
        end
        result[:errors] = errors if errors.length > 0
        result
      end

      ##
      # Return field properties for frontend application for actions 'edit', 'new' and type 'datetime'
      # @param model [ActiveRecord] field's model
      # @param action [Srting] current field action
      # @param mod [ActiveRecord] initialized new model element
      # @return [Hash] field's properties for defined action
      def properties_forms_datetime (model, action, mod)
        result = {}
        errors = {}
        res = model.validators_on(self.key.to_sym).detect { |v| v.is_a?(ActiveModel::Validations::PresenceValidator) }
        if res
          result[:required] = true
          errors[:required] = model.human_attribute_name(self.key) + ' ' + mod.errors.generate_message(self.key.to_sym, :blank)
        end
        result[:format] = self.format
        result[:errors] = errors if errors.length > 0
        result
      end

      ##
      # Generates hash representation of all class parameters,
      # @return [Hash] hash representation of all data
      def to_h
        result = {
            key: self.key,
            type: self.type,
            visible: self.visible,
            field: self.field,
            table_field: self.table_field,
            error_text: self.error_text,
            autocomplete: self.autocomplete
        }
        result[:format] = self.format if self.type == 'datetime'
        if self.editable
          result[:editable] = self.editable
          result[:field] = self.model.title if self.model
        else
          result[:editable] = self.editable if self.editable != nil
        end
        if self.model
          result[:model] = self.model.to_h
        end
        if self.options
          result[:options] = self.options.to_h
        end
        if self.order
          result[:order] = self.order.to_h
        end
        result
      end

      ##
      # Convert hash to array json output
      # @param hash [Hash] hash representation
      # @return [Array] array representation
      def hash_to_json(hash)
        result = []
        hash.each_key do |key|
          result.push({ key: key.to_s, value: hash[key] })
        end
        result
      end

      public :format
    end
  end
end