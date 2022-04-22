class Anoubis::Sso::Server::LoginController < Anoubis::Sso::Server::ApplicationController
  include ActionController::Cookies

  def authenticate?
    false
  end

  def system
    data = nil
    if params.key? :sso_system
      begin
        data = JSON.parse self.redis.get(self.redis_prefix + 'system:' + params[:sso_system].to_s), { symbolize_names: true }
      rescue
        data = nil
      end
    end

    data
  end

  def index
    params[:prompt] = 'yes' unless params.key? :prompt

    result = {
      result: 0,
      message: I18n.t('anoubis.success')
    }
    code = 200

    if self.system
      session = nil
      session = cookies[:session] if cookies.key? :session

      unless session
        redirect_to self.get_login_url
        return
      end

      begin
        ses_data = JSON.parse self.redis.get(self.redis_prefix + 'session:' + session), { symbolize_names: true }
      rescue
        ses_data = nil
      end

      if ses_data
        ses_data = nil if ses_data[:ttl] < Time.now

        if ses_data
          ses_data[:time] = Time.now

          user = self.user_model.load_cache self.redis, ses_data[:uuid]

          if user
            ses_data[:ttl] = Time.now + user[:timeout]
            self.redis.set(self.redis_prefix + 'session:' + session, ses_data.to_json, ex: user[:timeout])
          else
            ses_data = nil
          end
        else
          self.redis.del self.redis_prefix + 'session:' + session
        end
      end

      unless ses_data
        redirect_to self.get_login_url
        return
      end

      unless ses_data.key? :ttl
        redirect_to self.get_login_url
        return
      end

      if ses_data[:ttl] < Time.now
        redirect_to self.get_login_url
        return
      end

      url = self.system[:host]

      if params[:prompt] != 'none'
        url += self.system[:callback]
      else
        url += self.system[:silent]
      end

      url += '?'

      if params.key? :sso_path
        url += params[:sso_path] + '&'
      end
      url += 'sso_session=' + cookies[:session] + '&locale=' + self.locale

      redirect_to url
      return
    else
      result[:result] = -1
      result[:message] = I18n.t('core.errors.incorrect_system')
      code = 400
    end

    respond_to do |format|
      format.json { render json: result, status: code }
    end
  end

  def create
    result = {
      result: 0,
      message: I18n.t('anoubis.success')
    }
    code = 200

    if self.system
      if params.has_key?(:login) && params.has_key?(:password)
        user = self.user_model.where(login: params[:login].downcase, status: 1).first

        if user && user.authenticate(params[:password])
          if !user.auth_key
            user.save_cache
            cookies[:session] = {
              value: SecureRandom.hex(32),
              domain: self.domain_url
            }
            self.user_model.where(uuid: user.uuid).update_all(visited_at: Time.now)
            self.redis.set(self.redis_prefix + 'session:' + cookies[:session], { uuid: user.uuid, login: Time.now, time: Time.now, ttl: Time.now + user.timeout, update: Time.now + 5.minutes }.to_json, ex: user.timeout)
            result[:url] = self.system[:host] + '?'
            if params.key? :sso_path
              result[:url] += params[:sso_path] + '&'
            end
            result[:session] = cookies[:session]
            result[:url] += 'sso_session=' + cookies[:session] + '&locale=' + self.locale
          else
            result[:result] = -4
            result[:message] = I18n.t('login.errors.cant_login')
          end
        else
          result[:result] = -3
          result[:message] = I18n.t('login.errors.cant_login')
        end
      else
        result[:result] = -2
        result[:message] = I18n.t('core.errors.incorrect_parameters')
      end
    else
      result[:result] = -1
      result[:message] = I18n.t('core.errors.incorrect_system')
    end

    respond_to do |format|
      format.json { render json: result, status: code }
    end
  end

  def update
    result = {
      result: 0,
      message: I18n.t('anoubis.success')
    }

    if self.system
      begin
        ses_data = JSON.parse self.redis.get(self.redis_prefix + 'session:' + params[:session]), { symbolize_names: true }
      rescue
        ses_data = nil
      end

      if ses_data
        if ses_data[:ttl] > Time.now
          if params.key? :secret_key
            if self.system[:secret_key] == params[:secret_key]
              user_data = self.get_user_data_by_uuid ses_data[:uuid]

              if user_data
                ses_data[:time] = Time.now
                ses_data[:ttl] = Time.now + user_data.timeout
                if ses_data[:update] < Time.now
                  ses_data[:update] = Time.now + 5.minutes
                  self.user_model.where(uuid: ses_data[:uuid]).update_all(visited_at: Time.now)
                end
                self.redis.set self.redis_prefix + 'session:' + params[:session], ses_data.to_json, ex: user_data.timeout
              else
                result[:result] = -5
                result[:message] = I18n.t('core.errors.incorrect_parameters')
              end
            else
              result[:result] = -4
              result[:message] = I18n.t('core.errors.incorrect_parameters')
            end
          else
            result[:result] = -3
            result[:message] = I18n.t('core.errors.incorrect_parameters')
          end
        else
          self.redis.del self.redis_prefix + 'session:' + params[:session]
          result[:result] = -6
          result[:message] = I18n.t('core.errors.incorrect_parameters')
        end
      else
        result[:result] = -2
        result[:message] = I18n.t('core.errors.incorrect_parameters')
      end
    else
      result[:result] = -1
      result[:message] = I18n.t('core.errors.incorrect_system')
    end

    respond_to do |format|
      format.json { render json: result }
    end
  end

  def destroy
    result = {
      result: 0,
      message: I18n.t('anoubis.success')
    }

    begin
      ses_data = JSON.parse self.redis.get(self.redis_prefix + 'session:' + params[:session]), { symbolize_names: true }
    rescue
      ses_data = nil
    end

    if ses_data
      self.redis.del self.redis_prefix + 'session:' + params[:session]
    else
      result[:result] = -1
      result[:message] = I18n.t('core.errors.incorrect_parameters')
    end

    respond_to do |format|
      format.json { render json: result }
    end
  end

  ##
  # REST action returns current user UUID from SSO server. This action also make prolongation of session life.
  #
  # <b>API request:</b>
  #   GET /api/<version>/login/:session
  #
  # <b>Parameters:</b>
  # - <b>sso_system</b> (String) --- system UUID <i>(required value)</i>
  # - <b>sso_secret</b> (String) --- system secret key <i>(required value)</i>
  # - <b>locale</b> (String) --- the output language locale <i>(optional value)</i>
  #
  # <b>Request example:</b>
  #   curl --header "Content-Type: application/json" --header 'Authorization: Bearer <session-token>' http://<server>:<port>/api/<api-version>/login/<session>?sso_system=<sso_system>&sso_secret=<sso_secret_key>
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
  #     "uuid": "9adc7c0a-45ca-4436-b706-1807de6192e0"
  #   }
  def show
    result = {
      result: 0,
      message: I18n.t('anoubis.success')
    }

    if self.system
      begin
        ses_data = JSON.parse self.redis.get(self.redis_prefix + 'session:' + params[:session]), { symbolize_names: true }
      rescue
        ses_data = nil
      end

      if ses_data
        if ses_data[:ttl] > Time.now
          if params.key? :secret_key
            if self.system[:secret_key] == params[:secret_key]
              user_data = self.get_user_data_by_uuid ses_data[:uuid]

              if user_data
                self.format_user_output(user_data, result)
                result[:login_time] = ses_data[:login]
                ses_data[:time] = Time.now
                ses_data[:ttl] = Time.now + user_data.timeout
                if ses_data[:update] < Time.now
                  ses_data[:update] = Time.now + 5.minutes
                  self.user_model.where(uuid: ses_data[:uuid]).update_all(visited_at: Time.now)
                end
                self.redis.set self.redis_prefix + 'session:' + params[:session], ses_data.to_json, ex: user_data.timeout
              else
                result[:result] = -5
                result[:message] = I18n.t('core.errors.incorrect_parameters')
              end
            else
              result[:result] = -4
              result[:message] = I18n.t('core.errors.incorrect_parameters')
            end
          else
            result[:result] = -3
            result[:message] = I18n.t('core.errors.incorrect_parameters')
          end
        else
          self.redis.del self.redis_prefix + 'session:' + params[:session]
          result[:result] = -6
          result[:message] = I18n.t('core.errors.incorrect_parameters')
        end
      else
        result[:result] = -2
        result[:message] = I18n.t('core.errors.incorrect_parameters')
      end
    else
      result[:result] = -1
      result[:message] = I18n.t('core.errors.incorrect_system')
    end

    respond_to do |format|
      format.json { render json: result }
    end
  end

  def get_login_url
    prompt = true
    if params.key? :prompt
      prompt = false if params[:prompt] == 'none'
    end

    if prompt
      url = self.front_url + 'login?'
      if params.key? :sso_path
        url += 'sso_path=' + params[:sso_path] + '&'
      end
      url += 'sso_system=' + params[:sso_system] + '&locale=' + self.locale
    else
      url = self.system[:host] + self.system[:silent] + '?error=need-login'
    end


    return url
  end
end
