module Anubis
  module Core
    module Data
      ##
      # Module presents all callbacks called in actions.
      module Callbacks
        ##
        # Fires after data was received from server and placed in {Anubis::Output::Data#data self.output.data} array.
        # It's rewrote for change data before output.
        def after_get_table_data

        end

        ##
        # Fires before data will be verified and converted.
        # @param data [Hash] Data for update
        # @return [Hash] Processed data. If returned nil then update is terminated.
        def before_update_data(data)
          data
        end

        ##
        # Fires after data was was updated on the server and placed in {Anubis::Output::Data#data self.output.data} array.
        # It's rewrote for change data before output.
        def after_update_data

        end

        ##
        # Fires after data was was created in {Anubis::Output::Data#data self.output.data} array and before it saved to server.
        # It's rewrote for change data before output.
        # @param data [Hash] Data for create
        # @return [Hash] Processed data. If returned nil then update is terminated.
        def before_create_data(data)
          data
        end

        ##
        # Fires after data was was created on the server and placed in {Anubis::Output::Data#data self.output.data} array.
        # It's rewrote for change data before output.
        def after_create_data

        end

        ##
        # Fires right before output data to screen
        def before_output

        end

        ##
        # Fires when data output to json value
        def around_output(data)
          data
        end

        ##
        # Fires when data is destroyed
        def destroy_data
          if !self.etc.data.data.destroy
            self.output.errors.concat self.etc.data.data.errors.full_messages
            self.output.result = -4
          end
        end
      end
    end
  end
end
