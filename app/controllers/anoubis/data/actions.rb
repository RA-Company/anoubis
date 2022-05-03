module Anoubis
  module Data
    ##
    # Module presents all default actions for for {DataController}.
    module Actions
      ##
      # Default action of {DataController}. Procedure outputs data loaded from database table.
      # Authorization bearer is required.
      #
      # <b>API request:</b>
      #   GET /api/<version>/<controller>
      #
      # <b>Request Header:</b>
      #   {
      #     "Authorization": "Bearer <Session token>"
      #   }
      #
      # <b>Parameters:</b>
      # - <b>locale</b> (String) --- the output language locale <i>(optional value)</i>
      # - <b>offset</b> (String) --- starting number for selection <i>(optional value, default: 0)</i>
      # - <b>limit</b> (String) --- number of selected rows <i>(optional value, default: 10)</i>
      # - <b>tab</b> (String) --- the tab, is used for selected data <i>(optional value, default: first defined tab)</i>
      #
      # <b>Request example:</b>
      #   curl --header "Content-Type: application/json" --header 'Authorization: Bearer <session-token>' http://<server>:<port>/api/<api-version>/<controller>?offset=0&limit=10
      #
      # <b>Results:</b>
      #
      # Resulting data returns in JSON format.
      #
      # <b>Examples:</b>
      #
      # <b>Success:</b> HTTP response code 200
      #   {
      #     "result": 0,
      #     "message": "Successful",
      #     "count": 5,
      #     "tab": "inner",
      #     "offset": "0",
      #     "limit": "10",
      #     "timestamp": 1563169525,
      #     "fields": [
      #         {
      #             "prop": "title",
      #             "title": "Soldier Ttitle"
      #             "type": "string",
      #             "sortable": true
      #         },
      #         {
      #             "prop": "name",
      #             "title": "Soldier Name"
      #             "type": "string",
      #             "sortable": true
      #         },
      #         {
      #             "prop": "age",
      #             "title": "Girl Age"
      #             "type": "string",
      #             "sortable": true
      #         }
      #     ],
      #     "data": [
      #         {
      #             "id": 1,
      #             "sys_title": "Sailor Moon",
      #             "actions": {
      #                 "edit": "Edit: Sailor Moon",
      #                 "delete": "Delete: Sailor Moon"
      #             },
      #             "title": "Sailor Moon",
      #             "name": "Banny Tsukino",
      #             "age": 16,
      #             "state": "inner"
      #         },
      #         {
      #             "id": 2,
      #             "sys_title": "Sailor Mercury",
      #             "actions": {
      #                 "edit": "Edit: Sailor Mercury",
      #                 "delete": "Delete: Sailor Mercury"
      #             },
      #             "title": "Sailor Mercury",
      #             "name": "Amy Mitsuno",
      #             "age": 16,
      #             "state": "inner"
      #         }
      #     ]
      #   }
      def index
        self.etc.data = Anoubis::Etc::Data.new
        self.set_parent_model 'index'
        self.output = Anoubis::Output::Data.new
        self.output.count = self.get_table_data_count
        self.setup_fields
        self.output.limit = self.etc.data.limit
        self.output.offset = self.etc.data.offset
        self.output.fields = self.get_fields_properties if self.etc.time == 0
        self.output.filter = self.get_filter_properties if self.etc.time == 0
        self.output.data = self.get_table_data
        self.output.tab = self.etc.tab.tab
        self.output.sortable = self.is_sortable
        self.output.order = self.etc.tab.order if self.etc.tab.order != ''
        self.output.sort = self.etc.tab.sort if self.etc.tab.sort != nil
        self.after_get_table_data
        self.before_output

        render json: around_output(output.to_h)
      end

      ##
      # <i>Frame</i> action of {DataController}. Procedure outputs frame data information (title, tabs, frame buttons)
      # Authorization bearer is required.
      #
      # <b>API request:</b>
      #   GET /api/<version>/<controller>/frame
      #
      # <b>Request Header:</b>
      #   {
      #     "Authorization": "Bearer <Session token>"
      #   }
      #
      # <b>Parameters:</b>
      # - <b>locale</b> (String) --- the output language locale <i>(optional value)</i>
      # - <b>offset</b> (String) --- starting number for selection <i>(optional value, default: 0)</i>
      # - <b>limit</b> (String) --- number of selected rows <i>(optional value, default: 10)</i>
      # - <b>tab</b> (String) --- the tab, is used for selected data <i>(optional value, default: first defined tab)</i>
      #
      # <b>Request example:</b>
      #   curl --header "Content-Type: application/json" --header 'Authorization: Bearer <session-token>' http://<server>:<port>/api/<api-version>/<controller>/frame
      #
      # <b>Results:</b>
      #
      # Resulting data returns in JSON format.
      #
      # <b>Examples:</b>
      #
      # <b>Success:</b> HTTP response code 200
      #   {
      #     "result": 0,
      #     "message": "Successful",
      #     "timestamp": 1563271417,
      #     "title": "Sailor soldiers",
      #     "short": "Soldiers",
      #     "mode": "soldiers",
      #     "access": "write",
      #     "tabs": [
      #         {
      #             "tab": "inner",
      #             "title": "Inner Senshi",
      #             "buttons": [
      #                 {
      #                     "key": "new",
      #                     "mode": "single",
      #                     "type": "primary"
      #                 }
      #             ],
      #             "hint": "Shows only inner soldiers"
      #         },
      #         {
      #             "tab": "outer",
      #             "title": "Outer Senshi",
      #             "buttons": [
      #                 {
      #                     "key": "new",
      #                     "mode": "single",
      #                     "type": "primary"
      #                 },
      #                 {
      #                     "key": "delete",
      #                     "mode": "multiple",
      #                     "type": "danger"
      #                 }
      #             ]
      #         }
      #     ]
      #   }
      #
      #
      # <b>Error (session expired):</b> HTTP response code 422
      #   {
      #     "result": -1,
      #     "message": "Session expired",
      #     "timestamp": 1563271417,
      #     "tab": "inner"
      #   }
      def frame
        self.output = Anoubis::Output::Frame.new
        self.etc.data = Anoubis::Etc::Data.new unless etc.data
        self.etc.action = 'frame'
        if parent_model
          self.output.result = -2 unless self.get_parent_data
        end
        setup_frame
        before_output

        render json: around_output(output.to_h)
      end

      ##
      # <i>Show</i> action of {DataController}. Procedure outputs values for view form.
      # Authorization bearer is required.
      #
      # <b>API request:</b>
      #   GET /api/<version>/<controller>/<id>
      #
      # <b>Request Header:</b>
      #   {
      #     "Authorization": "Bearer <Session token>"
      #   }
      #
      # <b>Parameters:</b>
      # - <b>locale</b> (String) --- the output language locale <i>(optional value)</i>
      # - <b>tab</b> (String) --- the tab, is used for action <i>(optional value, default: first defined tab)</i>
      #
      # Resulting output title is took from translation file <lang>.yml at path:
      #   <lang>:
      #     <controller name divided by level>:
      #       edit:
      #         form:
      #           title: "Edit soldier %{title}"
      #
      # If this path isn't defined in translation file, then value is took from path:
      #   <lang>:
      #     anubis:
      #       form:
      #         titles:
      #           edit: "Edit element: %{title}"
      #
      # <b>Request example:</b>
      #   curl --header "Content-Type: application/json" --header 'Authorization: Bearer <session-token>' http://<server>:<port>/api/<api-version>/<controller>/<id>?tab=<tab>
      #
      # <b>Results:</b>
      #
      # Resulting data returns in JSON format.
      #
      # <b>Examples:</b>
      #
      # <b>Success:</b> HTTP response code 200
      #   {
      #     "result": 0,
      #     "message": "Successful",
      #     "timestamp": 1563271417,
      #     "tab": "inner",
      #     "title": "Edit soldier Sailor Mars",
      #     "values": {
      #         "id": 3,
      #         "title": "Sailor Mars",
      #         "name": "Rey Hino",
      #         "state_view": "Inner Senshi",
      #         "state": "inner"
      #     },
      #     "options": {
      #         "state": {
      #             "inner": "Inner Senshi",
      #             "outer": "Outer Senshi",
      #             "star": "Sailor Star"
      #         }
      #     }
      #   }
      #
      #
      # <b>Error (incorrect request id):</b> HTTP response code 200
      #   {
      #     "result": -2,
      #     "message": "Incorrect request parameters",
      #     "timestamp": 1563271417,
      #     "tab": "inner"
      #   }
      #
      #
      # <b>Error (session expired):</b> HTTP response code 422
      #   {
      #     "result": -1,
      #     "message": "Session expired",
      #     "timestamp": 1563271417,
      #     "tab": "inner"
      #   }
      def show
        self.output = Anoubis::Output::Edit.new
        self.set_parent_model 'show'
        self.output.tab = self.etc.tab.tab
        if params.key?(:value) && params.key?(:field)
          self.load_data_by_title params[:field], params[:value]
          params[:id] = self.etc.data.data.id if self.etc.data.data
        end
        if params.key? :id
          self.load_data_by_id params[:id] if !self.etc.data.data
          if self.etc.data.data
            self.output.values = self.get_data_row self.etc.data.data
            if params.key? :time
              self.output.options = self.get_data_options params[:time]
            else
              self.output.options = self.get_data_options 0
            end
            self.output.fields = self.get_fields_properties if self.etc.time == 0
          else
            self.output.result = -2
          end
        else
          self.output.result = -2
        end
        if self.output.result == 0
          self.output.title = I18n.t(format('%s.show.form.title', params[:controller].sub('/', '.')), title: self.output.values[:sys_title],
                                default: I18n.t('anoubis.form.titles.show', title: self.output.values[:sys_title]))
        end
        self.before_output

        render json: around_output(output.to_h)
      end

      ##
      # <i>New</i> action of {DataController}. Procedure outputs default values for create form.
      # Authorization bearer is required.
      #
      # <b>API request:</b>
      #   GET /api/<version>/<controller>/new
      #
      # <b>Request Header:</b>
      #   {
      #     "Authorization": "Bearer <Session token>"
      #   }
      #
      # <b>Parameters:</b>
      # - <b>locale</b> (String) --- the output language locale <i>(optional value)</i>
      # - <b>tab</b> (String) --- the tab, is used for action <i>(optional value, default: first defined tab)</i>
      #
      # Resulting output title is took from translation file <lang>.yml at path:
      #   <lang>:
      #     <controller name divided by level>:
      #       new:
      #         form:
      #           title: "Add new soldier"
      #
      # If this path isn't defined in translation file, then value is took from path:
      #   <lang>:
      #     anubis:
      #       form:
      #         titles:
      #           new: "Add new element"
      #
      # <b>Request example:</b>
      #   curl --header "Content-Type: application/json" --header 'Authorization: Bearer <session-token>' http://<server>:<port>/api/<api-version>/<controller>/new?tab=<tab>
      #
      # <b>Results:</b>
      #
      # Resulting data returns in JSON format.
      #
      # <b>Examples:</b>
      #
      # <b>Success:</b> HTTP response code 200
      #   {
      #     "result": 0,
      #     "message": "Successful",
      #     "timestamp": 1563271417,
      #     "tab": "inner",
      #     "title": "Add new soldier",
      #     "values": {
      #         "title": "",
      #         "name": "",
      #         "state_view": "Inner Senshi",
      #         "state": "inner"
      #     },
      #     "options": {
      #         "state": {
      #             "inner": "Inner Senshi",
      #             "outer": "Outer Senshi",
      #             "star": "Sailor Star"
      #         }
      #     }
      #   }
      #
      #
      # <b>Error (session expired):</b> HTTP response code 422
      #   {
      #     "result": -1,
      #     "message": "Session expired",
      #     "timestamp": 1563271417,
      #     "tab": "inner"
      #   }
      def new
        new_action_skeleton 'new'
      end

      def new_action_skeleton(action)
        self.output = Anoubis::Output::Edit.new
        self.set_parent_model action
        self.output.tab = self.etc.tab.tab
        if self.etc.tab.buttons.key? action.to_sym
          self.load_new_data action
          if etc.data.data
            self.output.values = get_data_row etc.data.data
            if params.key? :time
              self.output.options = get_data_options params[:time]
            else
              self.output.options = self.get_data_options 0
            end
            etc.action = 'new'
            self.output.fields = self.get_fields_properties if self.etc.time == 0
            etc.action = action
          else
            self.output.result = -2
          end
        else
          self.output.result = -1
        end
        if self.output.result == 0
          self.output.title = I18n.t(format('%s.%s.form.title', params[:controller].sub('/', '.'), action), default: I18n.t('anoubis.form.titles.new'))
        end
        self.before_output

        render json: around_output(output.to_h)
      end

      ##
      # <i>Create</i> action of {DataController}. Procedure inserts data into database.
      # Authorization bearer is required.
      #
      # <b>API request:</b>
      #   POST /api/<version>/<controller>/new
      #
      # <b>Request Header:</b>
      #   {
      #     "Authorization": "Bearer <Session token>"
      #   }
      #
      # <b>Parameters:</b>
      # - <b>locale</b> (String) --- the output language locale <i>(optional value)</i>
      # - <b>tab</b> (String) --- the tab, is used for action <i>(optional value, default: first defined tab)</i>
      # - <b>data</b> (String) --- inserted data <i>(required value)</i>
      #
      # <b>Request example:</b>
      #   curl --request POST --header "Content-Type: application/json" --header 'Authorization: Bearer <session-token>' --data='{"title": "Sailor Mars", "name": "Rey Hino", "state": "inner"}' http://<server>:<port>/api/<api-version>/<controller>/?tab=<tab>
      #
      # <b>Results:</b>
      #
      # Resulting data returns in JSON format.
      #
      # <b>Examples:</b>
      #
      # <b>Success:</b> HTTP response code 200
      #   {
      #     "result": 0,
      #     "message": "Successful",
      #     "timestamp": 1563271417,
      #     "tab": "inner",
      #     "values": {
      #         "id": 3,
      #         "sys_title": "Sailor Mars",
      #         "actions": {
      #           "edit": "Edit: Sailor Mars",
      #           "delete": "Delete: Sailor Mars"
      #         },
      #         "title": "Sailor Mars",
      #         "name": "Rey Hino",
      #         "state": "Inner Senshi",
      #         "raw_state": "inner"
      #     },
      #     "action": ""
      #   }
      #
      #
      # <b>Error (data presents):</b> HTTP response code 200
      #   {
      #     "result": -3,
      #     "message": "Error update data",
      #     "timestamp": 1563271417,
      #     "tab": "inner",
      #     "errors": [
      #       "Title already presents"
      #     ]
      #   }
      #
      #
      # <b>Error (session expired):</b> HTTP response code 422
      #   {
      #     "result": -1,
      #     "message": "Session expired",
      #     "timestamp": 1563271417,
      #     "tab": "inner"
      #   }
      def create
        self.output = Anoubis::Output::Update.new
        self.set_parent_model 'create'
        self.output.tab = self.etc.tab.tab
        if params.key? :data
          if self.etc.tab.buttons.key? :new
            self.load_new_data
            if self.etc.data.data
              self.setup_fields
              data = get_permited_params

              data = self.before_create_data data

              if data
                data.each_key do |key|
                  self.convert_view_to_db_value key, data[key]
                end

                if self.etc.data.data.respond_to? :tenant_id
                  if self.current_user.respond_to? :tenant_id
                    self.etc.data.data.tenant_id = self.current_user.tenant_id if !self.etc.data.data.tenant_id
                  end
                end

                if self.etc.data.data.save
                else
                  self.output.errors.concat self.etc.data.data.errors.full_messages
                end
              else
                self.output.result = -4
              end

              if self.output.errors.length == 0
                self.etc.data.fields = nil
                self.set_new_action 'index'
                self.output.values = self.get_data_row self.etc.data.data
                self.set_new_action 'create'
                self.after_create_data
              else
                self.output.result = -3
              end
            else
              self.output.result = -2
            end
          else
            self.output.result = -1
          end
        else
          self.output.result = -2
        end
        self.before_output

        render json: around_output(output.to_h)
      end

      ##
      # <i>Edit</i> action of {DataController}. Procedure outputs values for edit form.
      # Authorization bearer is required.
      #
      # <b>API request:</b>
      #   GET /api/<version>/<controller>/<id>/edit
      #
      # <b>Request Header:</b>
      #   {
      #     "Authorization": "Bearer <Session token>"
      #   }
      #
      # <b>Parameters:</b>
      # - <b>locale</b> (String) --- the output language locale <i>(optional value)</i>
      # - <b>tab</b> (String) --- the tab, is used for action <i>(optional value, default: first defined tab)</i>
      #
      # Resulting output title is took from translation file <lang>.yml at path:
      #   <lang>:
      #     <controller name divided by level>:
      #       edit:
      #         form:
      #           title: "Edit soldier %{title}"
      #
      # If this path isn't defined in translation file, then value is took from path:
      #   <lang>:
      #     anubis:
      #       form:
      #         titles:
      #           edit: "Edit element: %{title}"
      #
      # <b>Request example:</b>
      #   curl --header "Content-Type: application/json" --header 'Authorization: Bearer <session-token>' http://<server>:<port>/api/<api-version>/<controller>/<id>/edit?tab=<tab>
      #
      # <b>Results:</b>
      #
      # Resulting data returns in JSON format.
      #
      # <b>Examples:</b>
      #
      # <b>Success:</b> HTTP response code 200
      #   {
      #     "result": 0,
      #     "message": "Successful",
      #     "timestamp": 1563271417,
      #     "tab": "inner",
      #     "title": "Edit soldier Sailor Mars",
      #     "values": {
      #         "id": 3,
      #         "title": "Sailor Mars",
      #         "name": "Rey Hino",
      #         "state_view": "Inner Senshi",
      #         "state": "inner"
      #     },
      #     "options": {
      #         "state": {
      #             "inner": "Inner Senshi",
      #             "outer": "Outer Senshi",
      #             "star": "Sailor Star"
      #         }
      #     }
      #   }
      #
      #
      # <b>Error (incorrect request id):</b> HTTP response code 200
      #   {
      #     "result": -2,
      #     "message": "Incorrect request parameters",
      #     "timestamp": 1563271417,
      #     "tab": "inner"
      #   }
      #
      #
      # <b>Error (session expired):</b> HTTP response code 422
      #   {
      #     "result": -1,
      #     "message": "Session expired",
      #     "timestamp": 1563271417,
      #     "tab": "inner"
      #   }
      def edit
        self.output = Anoubis::Output::Edit.new
        self.set_parent_model 'edit'
        self.output.tab = self.etc.tab.tab
        if self.table_actions.include?('edit')
          if params.key?(:value) && params.key?(:field)
            self.load_data_by_title params[:field], params[:value]
            params[:id] = self.etc.data.data.id if self.etc.data.data
          end
          if params.key? :id
            self.load_data_by_id params[:id] if !self.etc.data.data
            if self.etc.data.data
              self.output.values = self.get_data_row self.etc.data.data
              if params.key? :time
                self.output.options = self.get_data_options params[:time]
              else
                self.output.options = self.get_data_options 0
              end
              self.output.fields = self.get_fields_properties if self.etc.time == 0
            else
              self.output.result = -2
            end
          else
            self.output.result = -2
          end
        else
          self.output.result = -1
        end
        if self.output.result == 0
          self.output.title = I18n.t(format('%s.edit.form.title', params[:controller].sub('/', '.')), title: self.output.values[:sys_title],
                                default: I18n.t('anoubis.form.titles.edit', title: self.output.values[:sys_title]))
        end
        self.before_output

        render json: around_output(output.to_h)
      end

      ##
      # <i>Update</i> action of {DataController}. Procedure updates data in database.
      # Authorization bearer is required.
      #
      # <b>API request:</b>
      #   PUT /api/<version>/<controller>/<id>/
      #
      # <b>Request Header:</b>
      #   {
      #     "Authorization": "Bearer <Session token>"
      #   }
      #
      # <b>Parameters:</b>
      # - <b>locale</b> (String) --- the output language locale <i>(optional value)</i>
      # - <b>tab</b> (String) --- the tab, is used for action <i>(optional value, default: first defined tab)</i>
      # - <b>data</b> (String) --- inserted data <i>(required value)</i>
      #
      # <b>Request example:</b>
      #   curl --request PUT --header "Content-Type: application/json" --header 'Authorization: Bearer <session-token>' --data='{"title": "Sailor Mars", "name": "Rey Hino", "state": "inner"}' http://<server>:<port>/api/<api-version>/<controller>/<id>/?tab=<tab>
      #
      # <b>Results:</b>
      #
      # Resulting data returns in JSON format.
      #
      # <b>Examples:</b>
      #
      # <b>Success:</b> HTTP response code 200
      #   {
      #     "result": 0,
      #     "message": "Successful",
      #     "timestamp": 1563271417,
      #     "tab": "inner",
      #     "values": {
      #         "id": 3,
      #         "sys_title": "Sailor Mars",
      #         "actions": {
      #           "edit": "Edit: Sailor Mars",
      #           "delete": "Delete: Sailor Mars"
      #         },
      #         "title": "Sailor Mars",
      #         "name": "Rey Hino",
      #         "state": "Inner Senshi",
      #         "raw_state": "inner"
      #     },
      #     "action": ""
      #   }
      #
      #
      # <b>Error (data presents):</b> HTTP response code 200
      #   {
      #     "result": -3,
      #     "message": "Error update data",
      #     "timestamp": 1563271417,
      #     "tab": "inner",
      #     "errors": [
      #       "Title already presents"
      #     ]
      #   }
      #
      #
      # <b>Error (session expired):</b> HTTP response code 422
      #   {
      #     "result": -1,
      #     "message": "Session expired",
      #     "timestamp": 1563271417,
      #     "tab": "inner"
      #   }
      def update
        self.output = Anoubis::Output::Update.new
        self.set_parent_model 'update'
        self.output.tab = self.etc.tab.tab
        if self.table_actions.include?('edit')
          if params.key?(:id) && params.key?(:data)
            self.load_data_by_id params[:id]
            if self.etc.data.data
              self.setup_fields
              data = get_permited_params

              data = self.before_update_data data

              if data
                data.each_key do |key|
                  self.convert_view_to_db_value key, data[key]
                end

                if self.etc.data.data.save
                else
                  self.output.errors.concat self.etc.data.data.errors.full_messages
                end

                if self.output.errors.length == 0
                  self.etc.data.fields = nil
                  self.set_new_action 'index'
                  self.output.values = self.get_data_row self.etc.data.data
                  self.output.action = 'refresh' if self.etc.data.data.need_refresh
                  self.set_new_action 'update'
                  self.after_update_data
                else
                  self.output.result = -3
                end
              end
            else
              self.output.result = -4
            end
          else
            self.output.result = -2
          end
        else
          self.output.result = -1
        end
        self.before_output

        render json: around_output(output.to_h)
      end

      ##
      # <i>Destroy</i> action of {DataController}. Procedure deletes data from database.
      # Authorization bearer is required.
      #
      # <b>API request:</b>
      #   DELETE /api/<version>/<controller>/<id>/
      #
      # <b>Request Header:</b>
      #   {
      #     "Authorization": "Bearer <Session token>"
      #   }
      #
      # <b>Parameters:</b>
      # - <b>locale</b> (String) --- the output language locale <i>(optional value)</i>
      # - <b>tab</b> (String) --- the tab, is used for action <i>(optional value, default: first defined tab)</i>
      #
      # <b>Request example:</b>
      #   curl --request DELETE --header "Content-Type: application/json" --header 'Authorization: Bearer <session-token>' http://<server>:<port>/api/<api-version>/<controller>/<id>/?tab=<tab>
      #
      # <b>Results:</b>
      #
      # Resulting data returns in JSON format.
      #
      # <b>Examples:</b>
      #
      # <b>Success:</b> HTTP response code 200
      #   {
      #     "result": 0,
      #     "message": "Successful",
      #     "timestamp": 1563271417,
      #     "tab": "inner"
      #   }
      #
      #
      # <b>Error (incorrect request id):</b> HTTP response code 200
      #   {
      #     "result": -2,
      #     "message": "Incorrect request parameters",
      #     "timestamp": 1563271417,
      #     "tab": "inner"
      #   }
      #
      #
      # <b>Error (session expired):</b> HTTP response code 422
      #   {
      #     "result": -1,
      #     "message": "Session expired",
      #     "timestamp": 1563271417,
      #     "tab": "inner"
      #   }
      def destroy
        self.output = Anoubis::Output::Delete.new
        self.set_parent_model 'destroy'
        self.output.tab = self.etc.tab.tab
        if self.etc.tab.buttons.key? :delete
          if params.key?(:value) && params.key?(:field)
            self.load_data_by_title params[:field], params[:value]
            params[:id] = self.etc.data.data.id if self.etc.data.data
          end
          if params.key?(:id)
            self.load_data_by_id params[:id] if !self.etc.data.data
            if self.etc.data.data
              self.output.id = self.etc.data.data.id
              if self.etc.data.data.can_delete( { tab: self.etc.tab } )
                self.destroy_data
              else
                self.output.result = -1
              end
            else
              self.output.result = -2
            end
          else
            self.output.result = -2
          end
        else
          self.output.result = -1
        end
        self.before_output

        render json: around_output(output.to_h)
      end

      ##
      # Returns autocomplete data
      def autocomplete
        self.output = Anoubis::Output::Autocomplete.new
        self.output.result = -1
        self.set_parent_model 'autocomplete'
        self.output.tab = self.etc.tab.tab
        if params.key?(:field) && params.key?(:value)
          self.setup_fields
          if self.etc.data.fields
            if self.etc.data.fields.key? params[:field].to_s.to_sym
              field = self.etc.data.fields[params[:field].to_s.to_sym]
              #puts 'autocomplete'
              #puts field.to_h
              if field.autocomplete
                self.output.result = 0
                self.get_autocomplete_data field, params[:value]
                #puts field.to_h
              end
            end
          end
        end
        self.before_output

        render json: around_output(output.to_h)
      end

      ##
      # Export data from database
      def export
        self.etc.data = Anoubis::Etc::Data.new
        self.set_parent_model 'export'
        self.output = Anoubis::Output::Data.new
        if self.etc.tab.export
          self.output.count = self.get_table_data_count
          count = (self.output.count / 40).to_i + 1
          self.setup_fields

          self.exports = Anoubis::Export.new format: self.export_format, fields: self.get_fields_properties

          case self.exports.format
          when 'xls'
            headers['Content-Disposition'] = 'attachment; filename="export.xlsx" filename*="export.xlsx"'
          end

          self.etc.data.limit = 40
          self.etc.data.offset = 0
          self.output.data = self.get_table_data
          self.after_get_table_data
          self.before_output
          self.exports.add self.output.data

          if count > 1
            for i in 2..count
              self.etc.data.offset = (i-1)*40
              self.output.data = self.get_table_data
              self.after_get_table_data
              self.before_output
              self.exports.add self.output.data
            end
          end

          respond_to do |format|
            case self.exports.format
            when 'xls'
              format.xlsx {
                send_data self.render_xls_file, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
              }
            end
          end
        else
          respond_to do |format|
            format.any { render json: {result: -1}, status: :unprocessable_entity }
          end

        end
      end

      ##
      # Returns rendered xlsx data
      def render_xls_file
        Axlsx::Package.new do |p|
          wb = p.workbook
          wb.styles do |s|
            default = s.add_style :sz => 11, :font_name => "Calibri", :alignment => {:vertical => :center}
            default_bold = s.add_style :sz => 11, :font_name => "Calibri", :alignment => {:vertical => :center}, :b => true
            wb.add_worksheet(name: 'Data') do |sheet|
              sheet.add_row self.exports.title, :style => default_bold
              self.exports.data.each do |data|
                sheet.add_row data, :style => default
              end
            end
          end
          return p.to_stream().read
        end
      end
    end
  end
end