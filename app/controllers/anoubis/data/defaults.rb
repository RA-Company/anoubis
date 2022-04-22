module Anoubis
  module Data
    ##
    # Module sets default parameters for {DataController}.
    module Defaults
      ##
      # Sets hash of defined tabs. Every tab consists of next attributes:
      #
      # *Attributes:*
      # - *:title* (String) --- title of the tab
      # - *:where* (Hash | Array) --- hash or array of where parameters for ActiveRecord request. If doesn't present
      #   then there are no additional where statements for current tab
      #
      # @return [Hash] returns hash of assigned tabs.
      #
      # @example Sets custom tabs
      #   def tabs
      #     {
      #         :all => {
      #             title: 'All IDs'
      #         },
      #         :id_1 => {
      #             title: 'Only ID 1',
      #             where: { id: 1 }
      #         },
      #         :other_id => {
      #             title: 'Other IDs',
      #             where: ['id > ?', 1]
      #         }
      #     }
      #   end
      def tabs
        {
          :default => {
            title: I18n.t('anoubis.default_tab'),
            tips: I18n.t('anoubis.default_tab_hint')
          }
        }
      end

      ##
      # Sets frame buttons for every using tab.
      # Key of the button is an action for frontend application. Every button consists of next attributes:
      #
      # *Attributes:*
      # - *:type* (String) <i>(defaults to: 'default')</i> --- type of the button ('primary', 'danger', 'default')
      # - *:mode* (String) <i>(defaults to: 'single')</i> --- button action object ('single', 'multiple')
      #
      # By default system defines two buttons: 'New' (for create new element in table) and 'Delete' (for
      # delete multiple element)
      #
      # @param [Hash] args additional parameters are used for define frame buttons.
      # @option args [String] :tab current tab is used for generation
      #
      # @return [Hash] returns hash of assigned buttons.
      #
      # @example Sets no buttons
      #   def frame_buttons(args = {})
      #     {
      #     }
      #   end
      #
      # @example Sets only 'New' button
      #   def frame_buttons(args = {})
      #     {
      #         new: { type: 'primary' }
      #     }
      #   end
      def frame_buttons(args = {})
        {
          new: { type: 'primary' },
          delete: { mode: 'multiple', type: 'danger' }
        }
      end

      ##
      # Returns model that is used for controller actions. By default it's not defined.
      # This is primary model and it must be defined in customer conroller. Different models may be defined according
      # by {Anoubis::Etc::Base#action self.etc.action} attribute.
      # @return [Anoubis::ApplicationRecord, nil, any] returns model
      def model
        nil
      end

      ##
      # Returns defined select fields. If returns nil, then return default select fields
      def select
        nil
      end

      ##
      # Returns eager load parameters that are used for controller actions. By default it's set to \[\].
      # This procedure could be redefined in cusomer controller. Different eager loads may be defined according
      # by {Anoubis::Etc::Base#action self.etc.action} attribute.
      def eager_load
        []
      end

      ##
      # Returns fields that is used for controller actions in defined {#model}. By default it's defined for id field.
      # This is primary definition and it must be defined in customer conroller. Different fields may be defined according
      # by {Anoubis::Etc::Base#action self.etc.action} attribute.
      # @return [Hash] returns defined fields for current model
      def fields
        {
          id: { type: 'number', precision: 0 }
        }
      end

      ##
      # Get array of field's identifiers in desired order. By default it's current defined order of all fields.
      def fields_order
        result = []
        self.etc.data.fields.each_key do |key|
          result.push key.to_s
        end
        result
      end

      ##
      # Get array of field's identifiers in desired order for filter form. By default it's current defined order of all fields.
      def filter_order
        self.fields_order
      end

      ##
      # Returns parent model that is used for controller actions. By default it's defined as <i>nil</i>.
      # This procedure could be redefined in customer controller. Different models may be defined according
      # by {Anoubis::Etc::Base#action self.etc.action} attribute.
      # @return [Anoubis::ApplicationRecord, nil] returns model
      def parent_model
        nil
      end

      ##
      # Returns eager load parameters for parent model  that are used for controller actions. By default it's set to \[\].
      # This procedure could be redefined in customer controller. Different eager loads may be defined according
      # by {Anoubis::Etc::Base#action self.etc.action} attribute.
      def parent_eager_load
        []
      end

      ##
      # Returns parent model id. By default it's set to 0.
      # This procedure could be rewrote in customer controller.
      def parent_id
        return 0
      end

      ##
      # @!group Block of default controller table actions

      ##
      # Sets default table actions for every row
      # @return [Array] return string array of action identifiers
      def table_actions
        %w[edit delete]
      end

      ##
      # Returns possibility of 'edit' action for current row
      # @param row [ActiveRecord] single model's data row
      def table_action_edit(row)
        row.can_edit({ controller: params[:controller], tab: self.etc.tab })
      end

      ##
      # Returns possibility of 'delete' action for current row
      # @param row [ActiveRecord] single model's data row
      def table_action_delete(row)
        row.can_delete({ controller: params[:controller], tab: self.etc.tab })
      end

      ##
      # Returns default where condition
      # @return [Hash, Array] default where condition
      def where
        []
      end

      #@!endgroup

      ##
      # Returns export format for current action. Procedure is rewrote for change default export format.
      def export_format
        'xls'
      end

      ##
      # Returns filter possibility for defined options. It's rewrote for custom controllers.
      # @param [Hash] args additional parameters.
      # @option args [String] :tab current tab is used for generation
      # @return [Boolean] Possibility of filter table data. Default: true
      def is_filter(args = {})
        true
      end

      ##
      # Returns export possibility for defined options. It's rewrote for custom controllers.
      # @param [Hash] args additional parameters.
      # @option args [String] :tab current tab is used for generation
      # @return [Boolean] Possibility of export table data. Default: true
      def is_export(args = {})
        true
      end

      ##
      # Returns field name for manual table order or nil if table can't be sorted manually.
      # @return [String] Field name for manual table order
      def is_sortable
        nil
      end
    end
  end
end
