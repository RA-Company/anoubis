class Anubis::Sso::Client::ApplicationController < Anubis::Core::ApplicationController

  def sso_server
    Rails.configuration.sso_server
  end

  def sso_system_uuid
    Rails.configuration.sso_system_uuid
  end

  def sso_system_secret
    Rails.configuration.sso_system_secret
  end

  def user_model
    begin
      model = Rails.configuration.user_model.classify.constantize
    rescue
      model = Anubis::Sso::Server::User
    end

    model
  end

  def authentication
    if !self.token
      self.error_exit({ error: I18n.t('errors.authentication_required') })
      return false
    end

    session = self.redis.get(self.redis_prefix + 'session:' + self.token)

    if !session
      session = self.get_session_from_sso_server self.token
    else
      session = JSON.parse(session,{ symbolize_names: true })
    end

    if !session
      self.error_exit({ error: I18n.t('errors.authentication_required') })
      return false
    end

    if session[:update].to_datetime + 300.seconds < Time.now
      session = self.get_session_from_sso_server self.token
    end

    if !session
      self.redis.del self.redis_prefix + 'session:' + self.token
      self.error_exit({ error: I18n.t('errors.authentication_required') })
      return false
    end

    if session[:time].to_datetime + session[:timeout].to_f / 86400 < Time.now
      self.redis.del self.redis_prefix + 'session:' + self.token
      self.error_exit({ error: I18n.t('errors.authentication_required') })
      return false
    end

    session[:time] = Time.now

    self.redis.set(self.redis_prefix + 'session:' + self.token, session.to_json, ex: session[:timeout])

    begin
      self.current_user = self.user_model.new(self.user_model.load_cache(self.redis, session[:uuid]))
    rescue
      self.current_user = nil
    end

    true
  end

  def get_session_from_sso_server(session)
    #require 'rest-client'

    #session = JSON.parse(RestClient.get(self.sso_server + 'api/1/login/' + session + '?sso_system=' + self.sso_system_uuid + '&secret_key=' + self.sso_system_secret + '&locale=' + self.locale), { symbolize_names: true })
    begin
      ses_data = JSON.parse(RestClient.get(self.sso_server + 'api/1/login/' + session + '?sso_system=' + self.sso_system_uuid + '&secret_key=' + self.sso_system_secret + '&locale=' + self.locale), { symbolize_names: true })
    rescue
      return nil
    end

    return nil if ses_data[:result] != 0


    user_data = self.get_user_data_by_uuid ses_data[:uuid], ses_data, true


    return {
      uuid: user_data.uuid,
      login: ses_data[:login_time],
      time: Time.now,
      timeout: user_data.timeout,
      update: Time.now
    }
  end

  ##
  # Returns user data by UUI
  def get_user_data_by_uuid(uuid, sso_data = nil, force = false)
    unless force
      begin
        user_data = self.user_model.new(JSON.parse(self.redis.get(self.redis_prefix + 'user:' + uuid), { symbolize_names: true }))
      rescue
        user_data = nil
      end
    end

    unless user_data
      user_data = self.user_model.find_or_create_by(uuid: uuid)

      user_data.save_cache(sso_data) if user_data
    end

    user_data
  end

  ##
  # Return access status for current user
  def menu_access(controller, exit = true)
    menu_access_status = 'not'

    if self.current_user
      if self.current_user.menus
        if self.current_user.menus.key? controller.to_s.to_sym
          menu_access_status = self.current_user.menus[controller.to_s.to_sym]
        end
      end
    end

    if menu_access_status == 'not'
      self.error_exit({ error: I18n.t('errors.access_not_allowed') }) if exit
      return false
    end

    self.writer = true if menu_access_status == 'write'
    true
  end
end