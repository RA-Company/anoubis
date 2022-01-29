class Anubis::Sso::Server::UserController < Anubis::Sso::Server::ApplicationController
  def authenticate?
    false
  end

  def show
    result = {
      result: 0,
      message: I18n.t('anubis.core.success')
    }
    code = 200

    self.get_user_data result

    respond_to do |format|
      format.json { render json: result, status: code }
    end
  end

  def show_current
    self.get_user_from_session
    self.show
  end

  def update
    result = {
      result: 0,
      message: I18n.t('anubis.core.success')
    }
    code = 200

    user_data = self.get_user_data result

    if user_data
      user_data.name = params[:name] if params.key? :name
      user_data.surname = params[:surname] if params.key? :surname
      user_data.timezone = params[:timezone] if params.key? :timezone
      user_data.locale = params[:locale] if params.key? :locale
      if params.key? :timeout
        user_data.timeout = params[:timeout] if params[:timeout].to_s.to_i > 60 && params[:timeout].to_s.to_i <= 36000
      end

      if user_data.save
        result[:uuid] = user_data.uuid
        result[:name] = user_data.name
        result[:surname] = user_data.surname
        result[:login] = user_data.login
        result[:locale] = user_data.locale
        result[:timezone] = user_data.timezone
        result[:timeout] = user_data.timeout
      else
        result[:uuid] = user_data.uuid_was
        result[:name] = user_data.name_was
        result[:surname] = user_data.surname_was
        result[:login] = user_data.login_was
        result[:locale] = user_data.locale_was
        result[:timezone] = user_data.timezone_was
        result[:timeout] = user_data.timeout_was
        result[:errors] = user_data.errors.full_messages
        result[:result] = -7
        result[:message] = I18n.t('anubis.core.errors.error_changing_data')
      end
    end

    respond_to do |format|
      format.json { render json: result, status: code }
    end
  end

  def update_current
    self.get_user_from_session
    self.update
  end

  def get_user_from_session
    session = self.get_current_session
    if session.key? :ttl
      if session[:ttl] > Time.now
        params[:uuid] = session[:uuid]
      end
    end
  end

  def get_current_session
    begin
      ses_data = JSON.parse self.redis.get(self.redis_prefix + 'session:' + params[:session]), { symbolize_names: true }
    rescue
      ses_data = { ttl: Time.now - 1.day }
    end

    ses_data
  end

  def get_user_data(result)
    user_data = nil

    if params.has_key? :session
      ses_data = self.get_current_session

      if ses_data[:ttl] > Time.now
        user_data = self.user_model.where(uuid: params[:uuid]).first

        if user_data
          begin
            adm_data = self.get_user_data_by_uuid ses_data[:uuid]
          rescue
            adm_data = nil
          end

          if adm_data
            if adm_data.role == 'user_role'
              if adm_data.id != user_data.id
                user_data = nil
              end
            end

            if user_data
              self.format_user_output user_data, result
            else
              result[:result] = -6
              result[:message] = I18n.t('anubis.core.errors.incorrect_parameters')
            end
          else
            result[:result] = -5
            result[:message] = I18n.t('anubis.core.errors.incorrect_parameters')
          end
        else
          result[:result] = -4
          result[:message] = I18n.t('anubis.core.errors.incorrect_parameters')
        end
      else
        result[:result] = -3
        result[:message] = I18n.t('anubis.core.errors.incorrect_parameters')
      end
    else
      result[:result] = -2
      result[:message] = I18n.t('anubis.core.errors.incorrect_parameters')
    end

    user_data
  end
end
