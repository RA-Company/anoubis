module Anoubis::Sso::Client::Index::Actions
  def menu
    self.output = Anoubis::Output::Menu.new

    if self.current_user
      self.output.user = {
        name: self.current_user.name,
        surname: self.current_user.surname,
        locale: self.current_user.locale
      }
    end

    access = Anoubis::Sso::Client::GroupMenu.accesses[:read].to_s+','+Anoubis::Sso::Client::GroupMenu.accesses[:write].to_s
    query = <<-SQL
          SELECT `t`.* FROM
            (
              SELECT `t2`.`id`, `t2`.`mode`, `t2`.`action`, `t2`.`title_locale`, `t2`.`page_title_locale`, `t2`.`short_title_locale`, 
                `t2`.`position`, `t2`.`tab`, `t2`.`menu_id`, `t2`.`state`, MAX(`t2`.`access`) AS `access`,
                `t2`.`user_id`, `t2`.`parent_mode`
              FROM (
                SELECT `menus`.`id`, `menus`.`id` AS `menu_id`, `menus`.`mode`, `menus`.`action`, `menus`.`title_locale`, `menus`.`page_title_locale`,
                  `menus`.`short_title_locale`, `menus`.`position`, `menus`.`tab`, `menus`.`menu_id` AS `parent_menu_id`, `menus`.`state`,
                  `group_menus`.`access`, `user_groups`.`user_id`, `parent_menu`.`mode` AS `parent_mode`
                FROM (`menus`, `group_menus`, `groups`, `user_groups`)
                  LEFT JOIN `menus` AS `parent_menu` ON `menus`.`menu_id` = `parent_menu`.`id`
                WHERE `menus`.`id` = `group_menus`.`menu_id` AND `menus`.`status` = 0 AND `group_menus`.`group_id` = `groups`.`id` AND
                  `groups`.`id` = `user_groups`.`group_id` AND `user_groups`.`user_id` = #{self.current_user.id}
                ) AS `t2`
               GROUP BY `t2`.`id`, `t2`.`mode`, `t2`.`action`, `t2`.`title_locale`, `t2`.`page_title_locale`, `t2`.`short_title_locale`,
                  `t2`.`position`, `t2`.`tab`, `t2`.`menu_id`, `t2`.`state`, `t2`.`user_id`, `t2`.`parent_mode`) AS `t`
               WHERE `t`.access IN (#{access}
            )
          ORDER BY `t`.`menu_id`, `t`.`position`
    SQL
    Anoubis::Sso::Client::GroupMenu.find_by_sql(query).each do |data|
      self.output.addElement({
                               mode: data.mode,
                               title: data.title,
                               page_title: data.page_title,
                               short_title: data.short_title,
                               position: data.position,
                               tab: data.tab,
                               action: data.action,
                               access: data.access,
                               state: Anoubis::Sso::Client::Menu.states.invert[data.state],
                               parent: data.parent_mode
                             })
      #self.output[:data].push menu_id[data.id.to_s.to_sym]
    end

    self.before_menu_output

    respond_to do |format|
      format.json { render json: around_menu_output(self.output.to_h) }
    end
  end

  def logout
    self.output = Anoubis::Output::Basic.new
    self.output.result = 0

    begin
      RestClient.delete self.sso_server + 'api/1/login/' + self.token + '?sso_system=' + self.sso_system_uuid + '&secret_key=' + self.sso_system_secret
      result = true
    rescue
      result = false
    end

    if result
      self.redis.del self.redis_prefix + 'session:' + self.token
    else
      self.output.result = -1
    end

    respond_to do |format|
      format.json { render json: around_menu_output(self.output.to_h) }
    end
  end
end