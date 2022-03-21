require_dependency "anoubis/output/login"

module Anoubis
  module Core
    ##
    # Module contains all procedures and function for {IndexController}. Consists of {Actions} and {Callbacks} module.
    module Index
      ##
      # Module contains all basic actions for {IndexController}.
      module Actions
        ##
        # <i>Logout</i> action of index controller. Procedure logouts user out of the system and deletes active sessions.
        # Authorization bearer is required. Procedure no need additional parameters.
        #
        # <b>API request:</b>
        #   POST /api/<version>/logout
        # <b>Request Header:</b>
        #   {
        #     "Authorization": "Bearer <Session token>"
        #   }
        # <b>Request example:</b>
        #   curl --header "Content-Type: application/json" -header 'Authorization: Bearer <session-token>' http://<server>:<port>/api/<api-version>/logout
        #
        # <b>Results:</b><br>
        #
        # Resulting data returns in JSON format.
        #
        # <b>Examples:</b>
        #
        # <b>Success:</b> HTTP response code 200
        #   {
        #     "result": 0,
        #     "message": "Successful"
        #   }
        #
        # <b>Error:</b> HTTP response code 422
        #   {
        #     "result": -1,
        #     "message": "Session expired"
        #   }
        def logout
          self.output = Anoubis::Output::Basic.new
          self.redis.del(self.redis_prefix + 'ses_'+self.token)
          respond_to do |format|
            format.json { render json: self.output.to_h }
          end
        end


      end
    end
  end
end