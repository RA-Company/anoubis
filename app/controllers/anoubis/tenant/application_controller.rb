class Anubis::Tenant::ApplicationController < Anubis::Core::ApplicationController
  ##
  # Get current user model
  # @return [ActiveRecord] defined user model. It is used for get current user data. May be redefined when user model is changed
  def get_user_model
    Anubis::Tenant::User
  end

  ##
  # Get current user model filed json exception
  # @return [Array] defined user exception for to_json function
  def get_user_model_except
    [:uuid_bin]
  end

  ##
  # Check menu access for current user of current controller
  # @return [Boolean] if true, then user have access for this controller.
  def menu_access(controller, exit = true)
    menu_access_status = redis.get self.redis_prefix + self.current_user.uuid+'_'+controller

    if !menu_access_status
      access = Anubis::Tenant::GroupMenu.accesses[:read].to_s+','+Anubis::Tenant::GroupMenu.accesses[:write].to_s
      query = <<-SQL
          SELECT `t`.* FROM
            (SELECT `menus`.`id`, `menus`.`mode`, `menus`.`action`, `menus`.`menu_id`,
              MAX(`group_menus`.`access`) AS `access`, `user_groups`.`user_id`
            FROM `menus`, `group_menus`, `groups`, `user_groups`
            WHERE `menus`.`mode` = '#{controller}' AND `menus`.`id` = `group_menus`.`menu_id` AND
              `menus`.`status` = 0 AND `group_menus`.`group_id` = `groups`.`id` AND `groups`.`id` = `user_groups`.`group_id` AND 
              `user_groups`.`user_id` = #{self.current_user.id}
            GROUP BY `menus`.`id`) AS `t`
            WHERE `t`.`access` IN (#{access})
            ORDER BY `t`.`menu_id`
      SQL
      menu = Anubis::Tenant::GroupMenu.find_by_sql(query).first
      if (!menu)
        redis.set self.redis_prefix + self.current_user.uuid+'_'+controller, 'not'
        self.error_exit({ error: I18n.t('errors.access_not_allowed') }) if exit
        return false
      end

      menu_access_status = menu.access
      redis.set self.redis_prefix + self.current_user.uuid+'_'+controller, menu_access_status
    else
      if menu_access_status == 'not'
        self.error_exit({ error: I18n.t('errors.access_not_allowed') }) if exit
        return false
      end
    end
    self.writer = true if menu_access_status == 'write'
    return true
  end
end