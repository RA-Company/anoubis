module Anoubis
  module Data
    ##
    # Module loads data from external sources for {DataController}
    module Load
      ##
      # Loads current menu data. Procedure loads menu data from MySQL database or from Redis cache and places it in
      # self.etc.menu {Anoubis::Etc#menu}
      def load_menu_data

      end

      ##
      # Load total number of rows of defined model in {Etc::Data#count}.
      def load_table_data_count
        #self.get_table_model.eager_load(self.get_table_eager_load).where(self.get_current_tab_where).where(self.get_table_where).where(self.etc.filter[:h]).where(self.etc.filter[:a]).count
        self.etc.data.count = self.get_model.eager_load(self.get_eager_load).where(self.get_tenant_where(self.get_model)).where(self.get_where).where(self.get_tab_where).where(self.get_filter_where_hash).where(self.get_filter_where_array).count
      end

      ##
      # Load model data into {Etc::Data#data}
      # @param limit [Integer] Specifies the maximum number of rows to return.
      # @param offset [Integer] Specifies the offset of the first row to return.
      def load_table_data(limit = 10, offset = 0)
        #self.etc.data.data = self.get_table_model.eager_load(self.get_table_eager_load).where(self.get_current_tab_where).where(self.get_table_where).where(self.etc.filter[:h]).where(self.etc.filter[:a]).order(self.get_current_order).limit(limit).offset(offset)
        if self.select
          self.etc.data.data = self.get_model.select(self.select).eager_load(self.get_eager_load).where(self.get_tenant_where(self.get_model)).where(self.get_where).where(self.get_tab_where).where(self.get_filter_where_hash).where(self.get_filter_where_array).order(self.get_order).limit(limit).offset(offset)
        else
          self.etc.data.data = self.get_model.eager_load(self.get_eager_load).where(self.get_tenant_where(self.get_model)).where(self.get_where).where(self.get_tab_where).where(self.get_filter_where_hash).where(self.get_filter_where_array).order(self.get_order).limit(limit).offset(offset)
        end
      end

      ##
      # Load single row of data into {Etc::Data#data}
      # @param id [Integer] Data's identifier.
      # @return [ActiveRecord|nil] Returns table data or nil if data absent
      def load_data_by_id(id)
        begin
          self.etc.data.data = self.get_model.eager_load(self.get_eager_load).where(self.get_tenant_where(self.get_model)).where(self.get_where).where(self.get_tab_where).find(id)
        rescue => error
          puts error
          self.etc.data.data = nil
        end
      end

      ##
      # Load single row of data into {Etc::Data#data}
      # @param field [String] Field's identifier.
      # @param value [String] Field's value.
      # @return [ActiveRecord|nil] Returns table data or nil if data absent
      def load_data_by_title(field, value)
        where = {}
        where[field.to_s.to_sym] = value
        begin
          self.etc.data.data = self.get_model.eager_load(self.get_eager_load).where(self.get_tenant_where(self.get_model)).where(self.get_where).where(self.get_tab_where).where(where).first
        rescue => error
          puts error
          self.etc.data.data = nil
        end
      end

      ##
      # Load predefined model data into {Etc::Data#data}
      # @return [ActiveRecord] Returns predefined data
      def load_new_data(action = 'new')
        self.etc.data.data = self.get_model.eager_load(self.get_eager_load).new
      end

      ##
      # Load data for autocomplete action from database
      # @param field [Anoubis::Etc::Field] - field for loading data
      def load_autocomplete_data(field)
        self.etc.data.data = field.model.model.where(field.model.where).where(field.autocomplete[:where]).where(get_tenant_where(field.model.model)).order(field.model.order).limit(field.autocomplete[:limit])
      end

      ##
      # Loads parent data from database
      def load_parent_data
        begin
          self.etc.data.parent = self.parent_model.where(self.get_tenant_where(self.parent_model)).find(self.parent_id)
        rescue
          self.etc.data.parent = nil
        end
      end
    end
  end
end
