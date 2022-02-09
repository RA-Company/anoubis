module Anoubis
  module Etc
    ##
    # Definitions of filter options for data.
    class Filter
      # @!attribute [rw]
      # Defines row filter data
      # @return [Hash,nil] row filter data.
      class_attribute :data, default: nil

      # @!attribute [rw]
      # Defines ActiveRecord hash representation of where.
      # @return [FieldOrder] hash representation of where
      class_attribute :hash, default: {}

      # @!attribute [rw]
      # Defines ActiveRecord array representation of where.
      # @return [FieldOrder] array representation of where
      class_attribute :array, default: []

      # @!attribute [rw]
      # Defines reference for fields
      # @return [Hash<Anoubis::Etc::Field>] hash of fields
      class_attribute :fields, default: nil

      ##
      # Sets default parameters for filter
      def initialize(options = {})
        self.fields = if options.key? :fields then options[:fields] else {} end
        self.hash = {}
        self.array = []
        if options.key? :data then self.init_data(options[:data]) else self.data end
      end

      ##
      # Generates hash representation of all class parameters,
      # @return [Hash] hash representation of all data
      def to_h
        result = {
            data: self.data,
            hash: self.hash,
            array: self.array,
            fields: {}
        }
        self.fields.each_key do |key|
          result[:fields][key] = self.fields[key].to_h
        end
        result
      end

      ##
      # Initializes all where parameters according by data and fields.
      # @param data [Hash] Collection of filter parameters in format <i>field: value</i>
      def init_data(data = nil)
        self.data = if data then data else {} end

        if self.fields
          self.fields.each do |key, field|
            if self.data.key? key.to_s
              proc = format('init_data_%s', field.type)
              result = self.send proc, key, self.data[key.to_s]
            end
          end
        end
      end

      ##
      # Initializes where parameters for filed with type string.
      # @param key [Symbol] Filed identifier
      # @param value [String] Filter parameters
      def init_data_string(key, value)
        words = value.split(' ')

        words.each do |word|
          self.attach_to_array self.fields[key].table_field.to_s+' LIKE ?'
          self.array.push("%#{word}%")
        end
      end

      ##
      # Initializes where parameters for filed with type text.
      # @param key [Symbol] Filed identifier
      # @param value [String] Filter parameters
      def init_data_text(key, value)
        words = value.split(' ')

        words.each do |word|
          self.attach_to_array self.fields[key].table_field.to_s+' LIKE ?'
          self.array.push("%#{word}%")
        end
      end

      ##
      # Initializes where parameters for filed with type number.
      # @param key [Symbol] Filed identifier
      # @param value [String] Filter parameters
      def init_data_number(key, value)
        if value.index ','
          if self.fields[key].table_field.to_s.include? '.'
            self.attach_to_array self.fields[key].table_field.to_s + ' IN (?)'
            self.array.push(value.split ',')
          else
            self.hash[key] = value.split ','
          end
          return
        end

        if value.index '>'
          if value.to_s.include? '.'
            result_value = value.to_s[1..100].to_f
          else
            result_value = value.to_s[1..100].to_i
          end
          if self.fields[key].table_field.to_s.include? '.'
            self.attach_to_array self.fields[key].table_field.to_s + ' > ?'

            self.array.push(result_value)
          else
            self.hash[key] = [result_value..Float::INFINITY]
          end
          return
        end

        if value.index '<'
          if value.to_s.include? '.'
            result_value = value.to_s[1..100].to_f
          else
            result_value = value.to_s[1..100].to_i
          end
          if self.fields[key].table_field.to_s.include? '.'
            self.attach_to_array self.fields[key].table_field.to_s + ' < ?'
            self.array.push(result_value)
          else
            self.hash[key] = [-Float::INFINITY..result_value]
          end
          return
        end

        if value.index '-'
          data = value.split '-'
          if data[0].include? '.'
            min_value = data[0].to_f
          else
            min_value = data[0].to_i
          end
          if data[1].include? '.'
            max_value = data[1].to_f
          else
            max_value = data[1].to_i
          end
          min_value, max_value = max_value, min_value if min_value > max_value
          if self.fields[key].table_field.to_s.include? '.'
            self.attach_to_array self.fields[key].table_field.to_s + ' > ? AND ' + self.fields[key].table_field.to_s + ' < ?'
            self.array.push(min_value)
            self.array.push(max_value)
          else
            self.hash[key] = [min_value..max_value]
          end
          return
        end

        if self.fields[key].table_field.to_s.include? '.'
          self.attach_to_array self.fields[key].table_field.to_s + ' = ?'
          self.array.push(value)
        else
          self.hash[key] = value
        end
      end

      ##
      # Initializes where parameters for filed with type listbox.
      # @param key [Symbol] Filed identifier
      # @param value [String] Filter parameters
      def init_data_listbox(key, value)
        values = []
        if value.class == Array
          value.each do |data|
            if self.fields[key].options.enum
              values.push self.fields[key].options.enum[data]
            else
              values.push data
            end
          end
        end
        if values.count > 0
          if self.fields[key].table_field.to_s.include? '.'
            self.attach_to_array self.fields[key].table_field.to_s + ' IN (?)'
            self.array.push(values)
          else
            self.hash[self.fields[key].table_field] = values
          end
        end
      end

      ##
      # Initializes where parameters for filed with type key.
      # @param key [Symbol] Filed identifier
      # @param value [String] Filter parameters
      def init_data_key(key, value)
        words = value.split(' ')

        words.each do |word|
          self.attach_to_array self.fields[key].table_field.to_s + ' LIKE ?'
          self.array.push("%#{word}%")
        end
      end

      ##
      # Attach parameters to where
      # @param str [String] attached parameters
      def attach_to_array(str)
        if self.array.count == 0
          self.array.push(str)
        else
          self.array[0] += ' AND ' + str
        end
      end

      ##
      # Initializes where parameters for filed with type 'datetime'.
      # @param key [Symbol] Filed identifier
      # @param value [String] Filter parameters
      def init_data_datetime(key, value)
        if value.class == Array
          if value.count == 2
            begin
              from = Time.parse value[0]
              to = Time.parse value[1]
            rescue
              from = nil
              to = nil
            end
            if from && to
              self.hash[key] = [ from..to ]
            end
          end
        end
        #words = value.split(' ')

#        words.each do |word|
#          if self.array.count == 0
#            self.array.push(self.fields[key].table_field.to_s + ' LIKE ?')
#          else
#            self.array[0] += ' AND '+self.fields[key].table_field.to_s+' LIKE ?'
#          end
#          self.array.push("%#{word}%")
#        end
      end
    end
  end
end