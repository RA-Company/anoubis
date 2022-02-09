class Anoubis::Sso::Client::User < Anoubis::Sso::Client::ApplicationRecord
  self.table_name = 'users'

  after_destroy :after_destroy_anubis_sso_client_user
  after_save :after_save_anubis_sso_client_user

  attr_accessor :name
  attr_accessor :surname
  attr_accessor :locale
  attr_accessor :timeout
  attr_accessor :timezone
  attr_accessor :menus

  def save_cache(sso_data)
    if sso_data
      self.name = sso_data[:name] if sso_data.key? :name
      self.surname = sso_data[:surname] if sso_data.key? :surname
      self.locale = sso_data[:locale] if sso_data.key? :locale
      self.timeout = sso_data[:timeout] if sso_data.key? :timeout
      self.timezone = sso_data[:timezone] if sso_data.key? :timezone
    end
    self.redis.set(self.redis_prefix + 'user:' + self.uuid, self.to_json) if self.redis
  end

  def clear_cache
    self.redis.del(self.redis_prefix + 'user:' + self.uuid) if self.redis
  end

  def self.load_cache(redis, uuid)
    begin
      data = JSON.parse redis.get(User.redis_prefix + 'user:' + uuid), { symbolize_names: true }
    rescue
      data = nil
    end

    unless data
      user = self.where(uuid: uuid).first
      if user
        return JSON.parse(user.to_json(except: [:password_digest]), { symbolize_names: true })
      end
    end

    data
  end

  def attributes
    super.merge({
      name: self.name,
      surname: self.surname,
      locale: self.locale,
      timeout: self.timeout,
      timezone: self.timezone,
      menus: self.get_menus
    })
  end

  def after_save_anubis_sso_client_user
    self.clear_cache
  end

  def after_destroy_anubis_sso_client_user
    self.clear_cache
  end

  def get_menus
    self.menus = {}
    access = Anoubis::Sso::Client::GroupMenu.accesses[:read].to_s+','+Anoubis::Sso::Client::GroupMenu.accesses[:write].to_s
    query = <<-SQL
          SELECT `menus`.`id`, `menus`.`mode`, MAX(`group_menus`.`access`) AS `access`
          FROM (`menus`, `group_menus`, `groups`, `user_groups`)
          WHERE `menus`.`status` = 0 AND `menus`.`id` = `group_menus`.`menu_id` AND `group_menus`.`access` IN (#{access}) AND `group_menus`.`group_id` = `groups`.`id` AND
            `groups`.`id` = `user_groups`.`group_id` AND `user_groups`.`user_id` = #{self.id} 
          GROUP BY `menus`.`id`, `menus`.`mode`
    SQL
    Anoubis::Sso::Client::GroupMenu.find_by_sql(query).each do |data|
      self.menus[data[:mode]] = data.access
    end

    self.menus
  end
end