module Anoubis
  ##
  # Module consists all procedures and functons of {DataController}
  module Core
    module Data
      ##
      # Module setups system parameters for {DataController}
      module Setup
        ##
        # Setups frame data information. It loads menu data, sets titles and tabs of the frame.
        def setup_frame
          self.load_menu_data
          if self.etc.menu
            self.get_parent_data
            if self.etc.data.parent
              self.output.title = self.etc.menu.page_title.sub '%{title}', self.etc.data.parent.sys_title.to_s
            else
              self.output.title = self.etc.menu.page_title
            end
            self.output.short = self.etc.menu.short_title
            self.output.mode = self.etc.menu.mode
            self.output.access = self.etc.menu.access
          end
          tabs = self.tabs
          tabs.each do |key, item|
            item = self.get_tab key, item
            self.output.addTab(item)
          end
        end

        ##
        # Setups order for current tab. Parameters is set into {Anoubis::Etc::TabItem#sort self.etc.tab.sort} and
        # {Anoubis::Etc::TabItem#order self.etc.tab.order} attributes.
        def setup_order
          sort = nil
          first = nil
          self.etc.data.fields.each do |key, field|
            if field.order
              first = key if !first
              first = key if field.order.default
              if params.key? :sort
                sort = key if params[:sort] == key.to_s
              end
            end
          end
          sort = first if !sort
          if sort
            self.etc.tab.sort = sort.to_s
            self.etc.tab.order = self.etc.data.fields[sort].order.order
            if params.key? :order
              self.etc.tab.order = :desc if params[:order] == 'desc'
              self.etc.tab.order = :asc if params[:order] == 'asc'
            end
          end
        end

        ##
        # @!group Block of fields setup functions

        ##
        # Setups defined fields and places it into attribute {Anoubis::Etc::Data#fields self.etc.data.fields}
        def setup_fields
          if !self.etc.data.fields
            self.etc.data.fields = {}

            fields = self.fields

            fields.each_key do |key|
              if fields[key].key? :edit
                if self.menu_access fields[key][:edit], false
                  fields[key][:editable] = fields[key][:edit]
                end
              end
              self.etc.data.fields[key] = Anoubis::Etc::Field.new(key, self.get_model, fields[key].merge(action: self.etc.action))
            end
            self.setup_order if %w[index export].include? self.etc.action
          end
        end

        ##
        # Setups additional parameters for table field with type 'datetime'
        # Resulting data placed in {Etc::Data#fields self.etc.data.fields} (Hash)
        # @param key [Symbol] key of table field.
        def setup_fields_datetime (key)
          self.etc.data.fields[key][:format] = 'full' if !self.etc.data.fields[key].has_key? :format
          self.etc.data.fields[key][:format] = 'full' if !['full', 'month', 'date', 'datetime'].include? self.etc.data.fields[key][:format]
        end



        ##
        # Setups additional parameters for table field with type 'float'
        # Resulting data placed in {Etc::Data#fields self.etc.data.fields} (Hash)
        # @param key [Symbol] key of table field.
        def setup_fields_float (key)
          self.etc.data.fields[key][:precision] = 2 if !self.etc.data.fields[key][:precision]
          self.etc.data.fields[key][:point] = ',' if !self.etc.data.fields[key][:point]
          self.etc.data.fields[key][:separator] = '' if !self.etc.data.fields[key][:separator]
        end
        # @!endgroup
      end
    end
  end
end
