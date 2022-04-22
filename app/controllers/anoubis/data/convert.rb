module Anoubis
  module Data
    ##
    # Data conversion moule between database and human representation
    module Convert
      ##
      # Format a number with grouped thousands
      # @param number [Float] The number being formatted.
      # @param precision [Integer] Sets the number of decimal points.
      # @param point [Char] Sets the separator for the decimal point.
      # @param separator [Char] Sets the thousands separator.
      # @return [String] A formatted version of number.
      def number_format(number, precision = 2, point = ',', separator = '')
        val = sprintf('%.'+precision.to_s+'f', number.round(precision)).to_s
        if separator != '' && number >= 1000
          whole_part, decimal_part = val.split('.')
          val = [whole_part.gsub(/(\d)(?=\d{3}+$)/, '\1'+separator), decimal_part].compact.join(point)
        else
          val = val.gsub('.', point)
        end
        val
      end


      ##
      # @!group Block of conversion database value into human view format

      ##
      # Convert value from database to view format according by defining field type and {Anoubis::Etc::Base#action action}
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [String] value from database
      def convert_db_to_view_value(key, value)
        field = self.etc.data.fields[key]
        return { key => value } if !field.type
        proc = format('convert_db_to_view_value_%s', field.type)
        result = self.send proc, key, value
        result
      end

      ##
      # Convert value from database to view format for 'string' type
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [String] value from database
      def convert_db_to_view_value_string(key, value)
        return { key => '' } if !value
        return { key => value }
      end

      ##
      # Convert value from database to view format for 'boolean' type
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [Boolean] value from database
      def convert_db_to_view_value_boolean(key, value)
        return { key => '' } if !value
        return { key => value }
      end

      ##
      # Convert value from database to view format for 'integer' type
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [String] value from database
      def convert_db_to_view_value_number(key, value)
        return { key => self.etc.data.fields[key].error_text } if !value
        return { key => value.to_s.to_i } if self.etc.data.fields[key].precision == 0
        return { key => format('%.' + self.etc.data.fields[key].precision.to_s + 'f', value) }
      end

      ##
      # Convert value from database to view format for 'text' type
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [String] value from database
      def convert_db_to_view_value_text(key, value)
        return { key => '' } if !value
        return { key => value }
      end

      ##
      # Convert value from database to view format for 'html' type
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [String] value from database
      def convert_db_to_view_value_html(key, value)
        return { key => '' } if !value
        return { key => value }
      end

      ##
      # Convert value from database to table format for 'listbox' type
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [String] value from database
      def convert_db_to_view_value_listbox(key, value)
        field = self.etc.data.fields[key]
        new_value = ''
        if field.options
          if field.format == 'single'
            new_value = field.options.list[value.to_s.to_sym] if field.options.list
          else
            new_value = []
            if value
              if field.options.list
                value.each do |key|
                  new_value.push field.options.list[key.to_s.to_sym]
                end
              end
            end
          end
        end
        case self.etc.action
        when 'index', 'show', 'export'
          if field.format == 'single'
            return { key => new_value, format('%s_raw', key).to_sym => value }
          else
            return { key => new_value.join(', '), format('%s_raw', key).to_sym => new_value }
          end
        when 'new', 'edit'
          if field.format == 'single'
            return { key => value.to_s, format('%s_view', key).to_sym => new_value }
          else
            return { key => value, format('%s_view', key).to_sym => new_value.join(', ') }
          end
        else
          if field.format == 'single'
            return { key => value.to_s, format('%s_view', key).to_sym => new_value }
          else
            return { key => value, format('%s_view', key).to_sym => new_value.join(', ') }
          end
        end
      end

      ##
      # Convert value from database to view format for 'key' type
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [String] value from database
      def convert_db_to_view_value_key(key, value)
        return { key => '' } if !value
        return { key => value }
      end

      ##
      # Convert value from database to table view for datetime type
      def convert_db_to_view_value_datetime(key, value)
        field = self.etc.data.fields[key]
        #puts key
        #puts value.class
        if (value.class == Date) || (value.class == ActiveSupport::TimeWithZone)
          begin
            new_value = case field.format
                        when 'month' then I18n.t('anubis.months.main')[value.month-1]+' '+value.year.to_s
                        when 'date' then value.day.to_s+' '+ I18n.t('anubis.months.second')[value.month-1]+' '+value.year.to_s
                        when 'datetime' then value.day.to_s+' '+ I18n.t('anubis.months.second')[value.month-1]+' '+value.year.to_s+', '+value.hour.to_s+':'+('%02d' % value.min)
                        else value.day.to_s+' '+ I18n.t('anubis.months.second')[value.month-1]+' '+value.year.to_s+', '+value.hour.to_s+':'+('%02d' % value.min)+':'+('%02d' % value.sec)
                        end
            if %w[month date].include? field.format
              raw_value = value.year.to_s + '-' + ('%02d' % value.month) + '-' + ('%02d' % value.day)
            else
              #raw_value = value.year.to_s + '-' + ('%02d' % value.month) + '-' + ('%02d' % value.day) + ' ' + ('%02d' % value.hour) + ':' + ('%02d' % value.min)
              raw_value = value.iso8601(2)[0..18]
            end
          rescue StandardError => e
            #puts e
            new_value = field.error_text
          end
        else
          new_value = '';
        end

        case self.etc.action
        when 'new', 'edit'
          return { key => raw_value, format('%s_view', key).to_sym => new_value }
        end
        return { key => new_value, format('%s_raw', key).to_sym => value }
      end
















      ##
      # Convert value from database to table view for text type
      def convert_db_to_table_value_text1(key, field, value)
        return { key => '', ('raw_'+key.to_s).to_sym => '' } if !value
        new_value = ERB::Util.html_escape(value).to_s.gsub(/(?:\n\r?|\r\n?)/, '<br/>')
        return { key => new_value, ('raw_'+key.to_s).to_sym => value }
      end





      ##
      # Convert value from database to table view for string type
      def convert_db_to_table_value_integer1(key, field, value)
        return { key => '' } if !value
        return { key => value }
      end




      ##
      # Convert value from database to table view for longlistbox type
      def convert_db_to_table_value_longlistbox1(key, field, value)
        return { key => '' } if !value
        return { key => value }
      end

      ##
      # Convert value from database to table view for datetime type
      def convert_db_to_table_value_datetime1(key, field, value)
        begin
          value = case field[:format]
                  when 'month' then I18n.t('months.main')[value.month-1]+' '+value.year.to_s
                  when 'date' then value.day.to_s+' '+ I18n.t('months.second')[value.month-1]+' '+value.year.to_s
                  when 'datetime' then value.day.to_s+' '+ I18n.t('months.second')[value.month-1]+' '+value.year.to_s+', '+value.hour.to_s+':'+('%02d' % value.min)
                  else value.day.to_s+' '+ I18n.t('months.second')[value.month-1]+' '+value.year.to_s+', '+value.hour.to_s+':'+('%02d' % value.min)+':'+('%02d' % value.sec)
                  end
        rescue
          value = I18n.t('incorrect_field_format')
        end
        return { key => value }
      end

      ##
      # Convert value from database to table view for float type
      # @param key [Symbol] key of table field
      # @param field [Tims::Etc::Table#fields] set of options of field by <b>key</b>
      # @param value [Float] value from database before processing
      # @return [Hash] return resulting value at format <b>{ key: processed_value, 'raw_'+key: value }</b>
      def convert_db_to_table_value_float1(key, field, value)
        return { key => number_format(value, field[:precision], field[:point], field[:separator]), ('raw_'+key.to_s).to_sym => value}
      end

      ##
      # Convert value from database to edit form for datetime type
      # @param key [Symbol] field's identifier
      # @param field [Hash] field's options
      # @param value [Any] value from database before processing
      # @return [Hash] resulting value in format <b>{ key: processed_value }</b>
      def convert_db_to_table_value_datetime(key, field, value)
        begin
          value = case field[:format]
                  when 'month' then I18n.t('months.main')[value.month-1]+' '+value.year.to_s
                  when 'date' then value.day.to_s+' '+ I18n.t('months.second')[value.month-1]+' '+value.year.to_s
                  when 'datetime' then value.day.to_s+' '+ I18n.t('months.second')[value.month-1]+' '+value.year.to_s+', '+value.hour.to_s+':'+('%02d' % value.min)
                  else value.day.to_s+' '+ I18n.t('months.second')[value.month-1]+' '+value.year.to_s+', '+value.hour.to_s+':'+('%02d' % value.min)+':'+('%02d' % value.sec)
                  end
        rescue
          value = I18n.t('incorrect_field_format')
        end
        return { key => value }
      end

      ##
      # Convert value from database to edit form for float type
      # @param key [Symbol] field's identifier
      # @param field [Anoubis::Etc::Data#fields] field's options
      # @param value [Float] value from database before processing
      # @return [Hash] return resulting value at format <b>{ key+'_view': processed_value, key: value }</b>
      def convert_db_to_table_value_float(key, field, value)
        return { (key.to_s+'_view').to_sym => number_format(value, field[:precision], field[:point], field[:separator]), key => value}
      end
      # @!endgroup


      ##
      # @!group Block of conversion human view values to database format

      ##
      # Converts inputted value to database format.
      # Field type is got from {Anoubis::Etc::Data#fields self.etc.data.fields} according by key.
      # Resulting data is placed into {Anoubis::Etc::Data#data self.etc.data.data} attribute according by key.
      # Errors are placed in {Anoubis::Output::Update#errors self.output.errors} array according by key.
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [String] value from user input
      def convert_view_to_db_value(key, value)
        field = self.etc.data.fields[key]
        return { key => value } unless field
        return { key => value } unless field.type
        proc = format('convert_view_to_db_value_%s', field.type)
        self.send proc, key, value
      end

      ##
      # Converts inputted value to database format for {Anoubis::Etc::Field#type 'string' field type}.
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [String] inputted value
      def convert_view_to_db_value_string(key, value)
        proc = format('self.etc.data.data.%s = value', key)
        #self.etc.data.data[key] = value
        eval proc
      end

      ##
      # Converts inputted value to database format for {Anoubis::Etc::Field#type 'boolean' field type}.
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [Boolean] inputted value
      def convert_view_to_db_value_boolean(key, value)
        proc = format('self.etc.data.data.%s = value', key)
        #self.etc.data.data[key] = value
        eval proc
      end

      ##
      # Converts inputted value to database format for {Anoubis::Etc::Field#type 'number' field type}.
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [String] inputted value
      def convert_view_to_db_value_number(key, value)
        field = self.etc.data.fields[key]
        if field.precision == 0
          value = value.to_s.to_i
        else
          value = value.to_s.to_f
        end
        proc = format('self.etc.data.data.%s = value', key)
        #self.etc.data.data[key] = value
        eval proc
      end

      ##
      # Converts inputted value to database format for {Anoubis::Etc::Field#type 'text' field type}.
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [String] inputted value
      def convert_view_to_db_value_text(key, value)
        proc = format('self.etc.data.data.%s = value', key)
        #self.etc.data.data[key] = value
        eval proc
      end

      ##
      # Converts inputted value to database format for {Anoubis::Etc::Field#type 'html' field type}.
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [String] inputted value
      def convert_view_to_db_value_html(key, value)
        proc = format('self.etc.data.data.%s = value', key)
        #self.etc.data.data[key] = value
        eval proc
      end

      ##
      # Converts inputted value to database format for {Anoubis::Etc::Field#type 'listbox' field type}
      # for {Anoubis::Data::Actions#create 'create'} action
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [String] inputted value
      def convert_view_to_db_value_listbox(key, value)
        field = self.etc.data.fields[key]
        begin
          proc = format('self.etc.data.data.%s = value', field.field)
          #self.etc.data.data[field.field] = value
          eval proc
        rescue
          self.etc.data.data[field.field] = nil
        end
      end

      ##
      # Converts inputted value to database format for {Anoubis::Etc::Field#type 'key' field type}
      # for {Anoubis::Data::Actions#create 'create'} action
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [String] inputted value
      def convert_view_to_db_value_key(key, value)
        field = self.etc.data.fields[key]
        where = {}
        where[field.model.title.to_s.to_sym] = value
        value = field.model.model.where(where).first
        proc = format('self.etc.data.data.%s = value', field.key)
        eval(proc)
        #begin
        #          self.etc.data.data[key] = value
        #        rescue
        #          self.etc.data.data[key] = nil
        #        end
      end

      ##
      # Converts inputted value to database format for {Anoubis::Etc::Field#type 'datetime' field type}.
      # @param key [Symbol] field's identifier in {Anoubis::Etc::Data#fields self.etc.data.fields} structure
      # @param value [String] inputted value
      def convert_view_to_db_value_datetime(key, value)
        zone = ActiveSupport::TimeZone[self.current_user.timezone]
        offset = if zone.utc_offset/3600 < 0 then (zone.utc_offset/3600).to_s else '+'+(zone.utc_offset/3600).to_s end
        #puts 'convert_view_to_db_value_datetime'
        #puts value
        value = Time.zone.parse value
        #puts value
        #puts zone
        #puts offset
        #puts value.utc_offset if value
        proc = format('self.etc.data.data.%s = value', key)
        #self.etc.data.data[key] = value
        eval proc
      end
      # @!endgroup
    end
  end
end