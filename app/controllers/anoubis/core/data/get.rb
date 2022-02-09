 module Anoubis
   module Core
     module Data
      ##
      # Module gets system data for {DataController}
      module Get
        ##
        # Get frame buttons data based on passed arguments.
        # @param [Hash] args additional parameters are used for define frame buttons.
        # @option args [String] :tab tab is used for generation buttons
        # @return [Hash] returns resulting button hash
        def get_frame_buttons(args = {})
          buttons = self.frame_buttons(args)
          buttons.each do |key, button|
            buttons[key] = self.get_frame_button key, button
          end
          buttons
        end

        ##
        # Get frame button
        # @param [String] key button identificator
        # @param [Hash] button initial button options
        # @option button [String] :type ('default') type of the button ('primary', 'danger', 'default')
        # @option button [String] :mode ('single') button action object ('single', 'multiple')
        # @option button [String] :title title of the frame. If title isn't defined then system is trying to take
        #   value from yml translation file at path <i>[<b><language>.<controller with dot>.frame.buttons.<key>.title</b>]</i> (eg.
        #   *en.anubis.tenants.frame.buttons.new.title* for english language 'anubis/tenants' controller 'new' button).
        #   If path absents then value isn't set.
        # @option button [String] :hint hint of the frame. If hint isn't defined then system is trying to take
        #   value from yml translation file at path <i>[<b><language>.<controller with dot>.frame.buttons.<key>.hint</b>]</i> (eg.
        #   *en.anubis.tenants.frame.buttons.new.hint* for english language 'anubis/tenants' controller 'new' button).
        #   If path absents then value isn't set.
        # @return [Hash] resulting button options
        def get_frame_button(key, button)
          button[:key] = key.to_s
          button[:type] = 'default' unless button.has_key? :type
          button[:mode] = 'single' unless button.has_key? :mode
          button[:decoration] = 'none' unless button.has_key? :decoration
          text = I18n.t('.buttons.'+button[:key]+'.title', default: '')
          button[:title] = text if text != ''
          text = I18n.t('.buttons.'+button[:key]+'.hint', default: '')
          button[:hint] = text if text != ''
          button
        end

        ##
        # Get tab parameters
        # @param [String] tab identifier
        # @param [Hash] options initial tab options
        # @option options [String] :title title of the frame. If title isn't defined then value is taken from yml
        #   translation file at path <i>[<b><language>.<controller with dot>.frame.tabs.<tab>.title</b>]</i> (eg.
        #   *en.anubis.tenants.frame.tabs.all.title* for english language 'anubis/tenants' controller 'all' tab).
        #   If path absents then value is set into humanized form of tab identifier (eg. 'All' for 'all' tab).
        # @option options [String] :hint hint of the frame. If hint isn't defined then system is trying to take
        #   value from yml translation file at path <i>[<b><language>.<controller with dot>.frame.tabs.<tab>.hint</b>]</i> (eg.
        #   *en.anubis.tenants.frame.tabs.all.hint* for english language 'anubis/tenants' controller 'all' tab).
        #   If path absents then value isn't set.
        def get_tab(tab, options = {})
          options[:tab] = tab.to_s
          options[:title] = I18n.t('.tabs.'+options[:tab]+'.title', default: options[:tab].humanize) if !options.key? :title
          if !options.has_key? :hint
            hint = I18n.t('.tabs.'+options[:tab]+'.hint', default: '')
            options[:hint] = hint if hint != ''
          end

          if options.key? :export
            options[:export] = true if options[:export].class != FalseClass
          else
            options[:export] = self.is_export({ tab: tab.to_s })
          end

          if options.key? :filter
            options[:filter] = true if options[:filter].class != FalseClass
          else
            options[:filter] = self.is_filter({ tab: tab.to_s })
          end
          options[:buttons] = self.get_frame_buttons({ tab: options[:tab] })
          #options[:where] = self.where if !options.key? :where
          options
        end

        ##
        # Get model that is used for controller action
        def get_model
          return self.etc.data.model if self.etc.data.model
          if defined? self.model
            self.etc.data.model = self.model
            self.etc.data.eager_load = self.eager_load
          end
          return self.etc.data.model
        end

        ##
        # Get default eager load definition for controller action
        def get_eager_load
          return self.etc.data.eager_load if self.etc.data.model
          self.get_model
          return self.etc.data.eager_load
        end

        ##
        # Get where for controller action fro defined tab
        def get_tab_where
          return self.etc.tab.where if self.etc.tab.where
          []
        end

        ##
        # Get where for controller action
        def get_where
          self.where
        end

        def get_tenant_where(model)
          return { tenant_id: self.current_user.tenant_id } if model.new.respond_to? :tenant_id
          return {}
        end

        def get_filter_where
          #puts 'get_filter_where!'
          #puts self.etc.data.filter.to_h
          return if self.etc.data.filter
          filter = {}
          if params.key? :filter
            begin
              filter = JSON.parse(params[:filter]).with_indifferent_access.to_h
            rescue
              filter = {}
            end
          end
          self.setup_fields
          #puts 'get_filter_where'
          #puts self.etc.data.fields
          self.etc.data.filter = Anoubis::Etc::Filter.new({ data: filter, fields: self.etc.data.fields })

          #puts self.etc.data.filter.to_h
        end

        def get_filter_where_hash
          self.get_filter_where
          return self.etc.data.filter.hash
        end

        def get_filter_where_array
          self.get_filter_where
          return self.etc.data.filter.array
        end

        ##
        # @!group Block of table data getters

        ##
        # Get total number of rows in defined model. Also sets additional system properties {Etc::Data#limit self.etc.data.limit},
        # {Etc::Data#offset self.etc.data.offset} and {Etc::Data#count self.etc.data.count}
        # @return [Integer] the total number of rows.
        def get_table_data_count
          self.load_table_data_count
          self.etc.data.limit = params[:limit] if params.has_key? :limit
          self.etc.data.offset = params[:offset] if params.has_key? :offset
          if self.etc.data.offset >= self.etc.data.count
            if self.etc.data.count > 0
              self.etc.data.offset = ((self.etc.data.count-1) / self.etc.data.limit).truncate * self.etc.data.limit
            else
              self.etc.data.offset = 0
            end
          end
          self.etc.data.count
        end

        ##
        # Returns fields for table output.
        # @return [Hash] calculated hash for fields properties for current action
        def get_fields_properties(fields = nil)
          fields = fields_order if !fields
          result = []
          fields.each do |value|
            if self.etc.data.fields
              if self.etc.data.fields.key? value.to_sym
                result.push self.etc.data.fields[value.to_sym].properties(self.etc.data.model, self.etc.action) if self.etc.data.fields[value.to_sym].visible
              end
            end
          end
          result
        end

        ##
        # Returns fields for filter form.
        # @return [Hash] calculated hash for fields properties for current action
        def get_filter_properties
          fields = filter_order
          self.get_fields_properties fields
        end

        ##
        # Load data into the system variable {Etc::Data#data self.etc.data.data} and return fields defined in controller.
        def get_table_data
          self.load_table_data self.etc.data.limit, self.etc.data.offset
          data = []
          if self.etc.data.data
            self.etc.data.data.each do |row|
              data.push get_data_row row
            end
          end
          data
        end

        ##
        # Get data fields defined in custom controller for single row
        # @param row [ActiveRecord] single row of model data
        # @return [Hash] calculated hash of model row
        def get_data_row(row)
          fields = self.get_fields

          new_row = {}

          case self.etc.action
          when 'show'
            new_row = { id: row.id, sys_title: row.sys_title }
          when 'index', 'export'
            new_row = { id: row.id, sys_title: row.sys_title, actions: self.get_table_actions(row) }
          when 'new', 'create'
            new_row = {}
          when 'edit', 'update'
            new_row = { id: row.id, sys_title: row.sys_title }
          end

          fields.each_key do |key|
            begin
              value = eval 'row.' + fields[key].field
              error = false
            rescue
              new_row[key] = fields[key].error_text
              error = true
              if fields[key].type == 'key'
                error = false
              end
            end

            new_row = new_row.merge(self.convert_db_to_view_value(key, value)) if !error
          end

          return new_row
        end

        ##
        # Returns current table actions for selected row
        # @param row [ActiveRecord] single row of model data
        # @return [Hash] resulting has of buttons
        def get_table_actions(row)
          self.etc.data.actions = self.table_actions if !self.etc.data.actions
          result = {}
          self.etc.data.actions.each do |value|
            if self.get_table_action value, row
              result[value.to_sym] = I18n.t(params[:controller].sub('/', '.')+'.table.actions.'+value, title: row.sys_title, default: I18n.t('actions.'+value, title: row.sys_title))
            end
          end
          result
        end

        ##
        # Returns posibility of using action for table data
        # @param action [String] desired action
        # @param row [ActiveRecord] single active record row
        # @return [Boolean] is action present or not
        def get_table_action(action, row)
          result = false
          if self.respond_to?(('table_action_'+action).to_sym)
            result = send 'table_action_'+action, row
          else
            result = true
          end
          result
        end
        # @!endgroup

        ##
        # @!group Block of {Anoubis::Data::Actions#edit edit} and {Anoubis::Data::Actions#update update} getters

        ##
        # Get model that is used for {Anoubis::Data::Actions#edit edit} or {Anoubis::Data::Actions#update update} actions.
        def get_edit_model
          return self.etc.data.model if self.etc.data.model
          self.etc.data.model = self.edit_model
          self.etc.data.eager_load = self.edit_eager_load
          return self.etc.data.model
        end

        ##
        # Get default eager load definition for {Anoubis::Data::Actions#edit edit} or
        # {Anoubis::Data::Actions#update update} actions.
        def get_edit_eager_load
          return self.etc.data.eager_load if self.etc.data.model
          self.get_edit_model
          return self.etc.data.eager_load
        end

        ##
        # Return current table fields hash for {Anoubis::Data::Actions#edit edit} or
        # {Anoubis::Data::Actions#update update} actions.
        # @return [Hash] current defined table fields
        def get_edit_fields
          self.setup_edit_fields
          self.etc.data.fields
        end

        ##
        # Get table data for single row for {Anoubis::Data::Actions#edit edit} or {Anoubis::Data::Actions#update update}
        # actions.
        # @param row [ActiveRecord] single row of model data
        # @return [Hash] calculated hash of model row
        def get_edit_data_row(row)
          self.setup_edit_fields
          new_row = { id: row.id, sys_title: row.sys_title }
          self.etc.data.fields.each do |key, field|
            if row.respond_to? field.field
              value = row.send field.field
              error = false
            else
              new_row[key] = field.error_text
              error = true
            end
            new_row = new_row.merge(self.convert_db_to_edit_value(key, value)) if !error
          end
          return new_row
        end

        # @!endgroup

        ##
        # @!group Block of {Anoubis::Data::Actions#new new} or {Anoubis::Data::Actions#create create} getters

        ##
        # Return current table fields hash for {Anoubis::Data::Actions#new new} or {Anoubis::Data::Actions#create create}
        # actions
        # @return [Hash] current defined table fields
        def get_new_fields
          self.setup_new_fields
          self.etc.data.fields
        end

        ##
        # Get table data for single row for {Anoubis::Data::Actions#new new} or {Anoubis::Data::Actions#create create}
        # actions.
        # @param row [ActiveRecord] single row of model data
        # @return [Hash] calculated hash of model row
        def get_new_data_row1(row)
          self.setup_new_fields
          new_row = {}
          self.etc.data.fields.each do |key, field|
            if row.respond_to? field.field
              value = row.send field.field
              error = false
            else
              new_row[key] = field.error_text
              error = true
            end
            new_row = new_row.merge(self.convert_db_to_new_value(key, value)) if !error
          end
          return new_row
        end

        # @!endgroup

        ##
        # Get defined fields options
        # @param time [Number] last execution time of action
        # @return [Hash] hash of fields options
        def get_data_options(time)
          time = time.to_s.to_i
          self.setup_fields
          result = {}
          self.etc.data.fields.each do |key, field|
            if field.options
              if field.options.list
                if time == 0
                  result[key] = field.options.list if field.options.show != 'never'
                else
                  if field.model
                    if field.options.show == 'always'
                      result[key] = field.options.list
                    else
                      if field.options.show == 'update' && field.model.updated_at > time
                        result[key] = field.options.list
                      end
                    end
                  else
                    result[key] = field.options.list if field.options.show == 'update' || field.options.show == 'always'
                  end
                end
              end
            end
          end
          result
        end

        ##
        # Returns order for current tab
        # @return [Hash, String] order fore current tab
        def get_order
          return {id: :desc} if self.etc.tab.sort == nil

          result = {}

          field = self.etc.data.fields[self.etc.tab.sort.to_sym].order
          if field.field.class == Symbol
            result[field.field] = self.etc.tab.order
          else
            if field.field.class == String
              if field.field.index(',')
                result = field.field.gsub(',', ' ' + self.etc.tab.order.to_s.upcase + ',') + ' ' + self.etc.tab.order.to_s.upcase
              else
                result = field.field + ' ' + self.etc.tab.order.to_s.upcase
              end
            else
              if field.field.class == Array
                field.field.each do |item|
                  if item.class == Symbol
                    result[item] = self.etc.tab.order
                  end
                end
              end
            end
          end
          result
        end

        ##
        # Return current fields hash for defined action.
        # @return [Hash] current defined table fields
        def get_fields
          self.setup_fields
          self.etc.data.fields
        end

        ##
        # Returns permitted parameters. Parameters is got from standard parameters output and checks according
        # by described {Anoubis::Etc::Data#fields self.etc.data.fields}.
        # @return [Hash<Symbol, string>] permitted paramters' collection
        def get_permited_params
          permit = []
          allowed = self.fields_order
          self.etc.data.fields.each_key do | key |
            single = true
            if self.etc.data.fields[key].type == 'listbox'
              single = false if self.etc.data.fields[key].format == 'multiple'
            end
            if single
              permit.push key
            else
              data = {}
              data[key] = []
              permit.push data
            end
          end
          params[:data].permit(permit).to_h.symbolize_keys
        end

        ##
        # Returns formatted field hash for field type 'string'
        # @param [Hash] options initial filed options
        # @option options [String] :min defines minimum string length <i>(default: 0)</i>
        # @option options [String] :max defines maximum string length <i>(default: 0)</i>
        # @return [Hash] resulting hash for field type 'string'
        def get_formatted_string_field(options)
          field = {}
          return field
        end

        ##
        # Get autocomplete data for field
        # @param field [Anoubis::Etc::Field] - field for loading data
        # @param value [String] - search value for load data
        # @return [Hash] resulting hash for selected data
        def get_autocomplete_data(field, value)
          value = value.to_s
          if value.index(' ')
            words = value.split(' ')

            max_count = 0;
            words.each do |word|
              max_count = word.length if word.length > max_count
              if field.autocomplete[:where].count == 0
                field.autocomplete[:where].push field.table_field+' LIKE ?'
              else
                field.autocomplete[:where][0] += ' AND '+field.table_field+' LIKE ?'
              end
              field.autocomplete[:where].push("%#{word}%")
            end
            if max_count < field.autocomplete[:count]
              field.autocomplete[:where] = []
            end
          else
            if value.length >= field.autocomplete[:count]
              field.autocomplete[:where] = [field.table_field+' LIKE ?', '%'+value+'%']
            end
          end
          if field.autocomplete[:where].count > 0
            self.load_autocomplete_data field
          end
          if self.etc.data.data
            self.etc.data.data.each do |item|
              if item.respond_to? field.model.title
                self.output.values.push(
                  #id: item.id,
                  value: item.send(field.model.title)
                )
              else
                self.output.values.push(
                  #id: item.id,
                  value: item.id
                )
              end
            end
          end
          return self.output.values
        end

        ##
        # Returns current parent data. If data not loaded then load it.
        # @return [ActiveRecord] resulting parent data
        def get_parent_data
          if !self.etc.data.parent
            self.load_parent_data
          end
          self.etc.data.parent
        end
      end
    end
  end
end
