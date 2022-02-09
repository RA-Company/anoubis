module Anoubis
  module Tenant
    module Index
      ##
      # Module contains all basic actions for {IndexController}.
      module Actions
        include Anoubis::Core::Index::Actions

        ##
        # <i>Login</i> action of index controller. Procedure checks user credential. If credentials are correct than user enters
        # into the system and procedure returns session token. If credentials are incorrect then procedure returns error.
        #
        # <b>API request:</b>
        #   POST /api/<version>/login
        # <b>Request body:</b>
        #   {
        #     "login": "login",
        #     "password": "password",
        #     "locale": "Country code"
        #   }
        # <b>Parameters:</b>
        # - <b>login</b> (String) -- the login of the user
        # - <b>password</b> (String) -- the password of the user
        # - <b>locale</b> (String) -- the output language locale <i>(optional value)</i>
        #
        # <b>Request example:</b>
        #   curl --header "Content-Type: application/json" --request POST --data '{"login":"<login>","password":"<password>"}' http://<server>:<port>/api/<api-version>/login
        #
        # <b>Results:</b><br>
        #
        # Resulting data is placed in self.output({Anoubis::OutputLogin}) class and returns in JSON format.
        #
        # <b>Examples:</b>
        #
        # <b>Success:</b> HTTP response code 200
        #   {
        #     "result": 0,
        #     "message": "Successful",
        #     "name": "Name",
        #     "surname": "Surname",
        #     "token": "Session token",
        #     "email": "e-mail"
        #   }
        #
        # <b>Error:</b> HTTP response code 422
        #   {
        #     "result": -1,
        #     "message": "Incorrect user login or password"
        #   }
        def login
          self.output = Anoubis::Output::Login.new
          if params.has_key?(:login) && params.has_key?(:password)
            user = Anoubis::Tenant::User.where(login: params[:login].downcase, status: 0).first

            if !user
              tenant = Anoubis::Tenant::Tenant.where(state: Anoubis::Tenant::Tenant.states[:default]).first
              user = Anoubis::Tenant::User.where(login: (params[:login]+'.'+tenant.ident).downcase, status: 0).first
            end

            if !user
              tenant = Anoubis::Tenant::Tenant.find(1)
              user = Anoubis::Tenant::User.where(login: (params[:login]+'.'+tenant.ident).downcase, status: 0).first
            end

            if user && user.authenticate(params[:password])
              if !user.auth_key
                self.redis_save_user(user)
                self.output.token = new_session_id
                self.output.name = user.name
                self.output.surname = user.surname
                self.output.email = user.email
                self.output.locale = user.locale
                self.redis.set(self.redis_prefix + 'session:' + self.output.token, { uuid: user.uuid, login: Time.now, time: Time.now, ttl: Time.now + user.timeout}.to_json)
              else
                self.output.result = -2
              end
            else
              self.output.result = -2
            end
          else
            self.output.result = -1
          end
          respond_to do |format|
            if self.output.result == 0
              format.json { render json: self.output.to_h }
            else
              format.json { render json: self.output.to_h, status: :unprocessable_entity }
            end
          end
        end

        ##
        # <i>Menu</i> action of index controller. Procedure outputs menu for current user in JSON format.
        # Authorization bearer is required.
        #
        # <b>API request:</b>
        #   GET /api/<version>/menu
        # <b>Request Header:</b>
        #   {
        #     "Authorization": "Bearer <Session token>"
        #   }
        #
        # <b>Parameters:</b>
        # - <b>locale</b> (String) -- the output language locale <i>(optional value)</i>
        #
        # <b>Request example:</b>
        #   curl --header "Content-Type: application/json" -header 'Authorization: Bearer <session-token>' http://<server>:<port>/api/<api-version>/menu?locale=en
        #
        # <b>Results:</b><br>
        #
        # Resulting data is placed in self.output({Anoubis::Output::Menu}) variable and returns in JSON format.
        #
        # <b>Examples:</b>
        #
        # <b>Success:</b> HTTP response code 200
        #   {
        #     "result": 0,
        #     "message": "Successful",
        #     "menu": {
        #       [{
        #         "mode": "admin/anubis",
        #         "title": "Administration",
        #         "page_title": "System administration",
        #         "short_title": "",
        #         "position": 0,
        #         "tab": 0,
        #         "action": "menu",
        #         "access": "read",
        #         "state": "visible",
        #         "parent": ""
        #       }]
        #     }
        #   }
        #
        # <b>Error:</b> HTTP response code 422
        #   {
        #     "result": -1,
        #     "message": "Session expired"
        #   }
        def menu
          self.output = Anoubis::Output::Menu.new
          access = Anoubis::Tenant::GroupMenu.accesses[:read].to_s+','+Anoubis::Tenant::GroupMenu.accesses[:write].to_s
          locale = Anoubis::Tenant::MenuLocale.locales[self.locale.to_s.to_sym]
          query = <<-SQL
          SELECT `t`.* FROM
            (
              SELECT `t2`.`id`, `t2`.`mode`, `t2`.`action`, `t2`.`title`, `t2`.`page_title`, `t2`.`short_title`, 
                `t2`.`position`, `t2`.`tab`, `t2`.`menu_id`, `t2`.`state`, MAX(`t2`.`access`) AS `access`,
                `t2`.`user_id`, `t2`.`parent_mode`
              FROM (
                SELECT `menus`.`id`, `menus`.`mode`, `menus`.`action`, `menu_locales`.`title`, `menu_locales`.`page_title`,
                  `menu_locales`.`short_title`, `menus`.`position`, `menus`.`tab`, `menus`.`menu_id`, `menus`.`state`,
                  `group_menus`.`access`, `user_groups`.`user_id`, `parent_menu`.`mode` AS `parent_mode`
                FROM (`menus`, `group_menus`, `groups`, `user_groups`)
                  LEFT JOIN `menu_locales` ON `menu_locales`.`menu_id` = `menus`.`id` AND `menu_locales`.`locale` = #{locale}
                  LEFT JOIN `menus` AS `parent_menu` ON `menus`.`menu_id` = `parent_menu`.`id`
                WHERE `menus`.`id` = `group_menus`.`menu_id` AND `menus`.`status` = 0 AND `group_menus`.`group_id` = `groups`.`id` AND
                  `groups`.`id` = `user_groups`.`group_id` AND `user_groups`.`user_id` = #{self.current_user.id}
                ) AS `t2`
               GROUP BY `t2`.`id`, `t2`.`mode`, `t2`.`action`, `t2`.`title`, `t2`.`page_title`, `t2`.`short_title`,
                  `t2`.`position`, `t2`.`tab`, `t2`.`menu_id`, `t2`.`state`, `t2`.`user_id`, `t2`.`parent_mode`) AS `t`
               WHERE `t`.access IN (#{access}
            )
          ORDER BY `t`.`menu_id`, `t`.`position`
          SQL
          Anoubis::Tenant::GroupMenu.find_by_sql(query).each do |data|
            self.output.addElement({
                                     mode: data.mode,
                                     title: data.title,
                                     page_title: data.page_title,
                                     short_title: data.short_title,
                                     position: data.position,
                                     tab: data.tab,
                                     action: data.action,
                                     access: data.access,
                                     state: Anoubis::Tenant::Menu.states.invert[data.state],
                                     parent: data.parent_mode
                                   })
            #self.output[:data].push menu_id[data.id.to_s.to_sym]
          end

          self.before_menu_output

          respond_to do |format|
            format.json { render json: around_menu_output(self.output.to_h) }
          end
        end
      end
    end
  end
end