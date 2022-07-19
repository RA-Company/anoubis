##
# Application controller for Anubis library.
class Anoubis::Core::ApplicationController < ActionController::API
  prepend_before_action :anubis_core_initialization

  #include AbstractController::Translation
  include ActionController::MimeResponds
  #include ActionController::Parameters
  #include ActionDispatch::Http::Parameters
  #include ActionDispatch::Request

  # @!attribute [rw] version
  #   @return [Integer] Specifies the api version. Parameters receive from URL <i>(defaults to: 0)</i>.
  attr_accessor :version

  # @!attribute [rw] locale
  #   @return [String] Specifies the current language locale <i>(defaults to: 'ru')</i>.
  #   Parameters receive from URL or user definition
  attr_accessor :locale

  # @!attribute [rw] current_user
  #   @return [ActiveRecord] Specifies current user <i>(defaults to: nil)</i>.
  attr_accessor :current_user

  # @!attribute [rw] output
  #    @return [Anoubis::Output] standard output.
  attr_accessor :output

  # @!attribute [rw] writer
  #   @return [Object] Specifies access of current user to this controller <i>(defaults to: false)</i>.
  attr_accessor :writer

  # @!attribute [rw] etc
  #   @return [Anoubis::Etc::Base] global system parameters
  attr_accessor :etc

  # @!attribute [rw] exports
  #   @return [Anoubis::Export] Export data class
  attr_accessor :exports

  ##
  # Returns redis database class
  def redis
    @redis ||= Redis.new( host: redis_host, port: redis_port )
  end

  ##
  # Sets default parameters for application controller.
  def anubis_core_initialization
    self.version = 0

    if defined? params
      self.etc = Anoubis::Etc::Base.new({ params: params })
    else
      self.etc = Anoubis::Etc::Base.new
    end
    self.output = nil
    self.exports = nil
    self.writer = false

    self.current_user = nil
    self.locale = params[:locale] if params.has_key? :locale
    self.locale = 'ru' unless self.locale
    self.locale = 'ru' if self.locale == ''
    begin
      I18n.locale = self.locale
    rescue
      I18n.locale = 'ru'
    end

    return if request.method == 'OPTIONS'

    if !params.has_key? :version
      self.error_exit({ error: I18n.t('errors.no_api_version') })
      return
    end

    if self.access_allowed?
      self.set_access_control_headers
    else
      self.error_exit({ error: I18n.t('errors.access_not_allowed') })
    end

    self.version = params[:version]

    if self.authenticate?
      if self.authentication
        if self.check_menu_access?
          return if !self.menu_access params[:controller]
        end
      end
    end

    #self.user_time_zone if self.current_user
    Time.zone = self.current_user.timezone if self.current_user
    self.after_initialization
  end

  ##
  # Calls after first controller initialization
  def after_initialization

  end


  ##
  # Gracefully terminate script execution with code 422 (Unprocessable entity). And JSON data
  # @param data [Hash] Resulting data
  # @option data [Integer] :code resulting error code
  # @option data [String] :error resulting error message
  def error_exit(data)
    result = {
      result: -1,
      message: 'Error'
    }
    result[:result] = data[:code] if data.has_key? :code
    result[:message] = data[:error] if data.has_key? :error
    respond_to do |format|
      format.json { render json: result, status: :unprocessable_entity }
    end
    begin
      exit
    rescue SystemExit => e

    end
  end

  ##
  # Get current user model
  # @return [ActiveRecord] defined user model. It is used for get current user data. May be redefined when user model is changed
  def get_user_model
    nil
  end

  ##
  # Get current user model filed json exception
  # @return [Array] defined user exception for to_json function
  def get_user_model_except
    []
  end

  ##
  # @!group Block of authorization

  ##
  # Checks if needed user authentication.
  # @return [Boolean] if true, then user must be authenticated.
  def authenticate?
    return true
  end

  ##
  # Authenticates user in the system
  def authentication
    if !self.token
      self.error_exit({ error: I18n.t('errors.authentication_required') })
      return false
    end

    # Check session presence
    session = self.redis.get(self.redis_prefix + 'session:' + self.token)
    if !session
      self.error_exit({ error: I18n.t('errors.session_expired') })
      return false
    end

    session = JSON.parse(session, { symbolize_names: true })

    if !session.has_key?(:uuid) || !session.has_key?(:ttl)
      self.error_exit({ error: I18n.t('errors.session_expired') })
      return false
    end

    if session[:ttl] < Time.now
      self.error_exit({ error: I18n.t('errors.session_expired') })
      self.redis.del(self.redis_prefix + 'session:' + self.token)
      return false
    end

    # Load user data from redis database
    user_json = self.redis.get(self.redis_prefix + 'user:' + session[:uuid])
    if !user_json
      # Check user presence based on session user UUID
      user = self.get_user_model.where(uuid_bin: self.uuid_to_bin(session[:uuid])).first
      if !user
        self.error_exit({ error: I18n.t('errors.authentication_required') })
        return false
      end
      user_json = self.redis_save_user user
    end

    begin
      self.current_user = self.get_user_model.new(JSON.parse(user_json,{ symbolize_names: true }))
    rescue
      self.current_user = nil
    end

    if !self.current_user
      self.error_exit({ error: I18n.t('errors.authentication_required') })
      return false
    end

    session[:time] = Time.now
    session[:ttl] = session[:time] + self.current_user.timeout
    self.redis.set(self.redis_prefix + 'session:' + self.token, session.to_json)

    true
  end

  ##
  # Checks user must have access for current controller.
  # @return [Boolean] if true, then user must have access for this controller.
  def check_menu_access?
    true
  end

  ##
  # Check menu access for current user of current controller
  # @return [Boolean] if true, then user have access for this controller.
  def menu_access(controller, exit = true)
    self.writer = true

    true
  end

  ##
  # Get current token based on HTTP Authorization
  # @return [String] current token
  def token
    if Rails.env.development?
      return params[:token] if params[:token]
    end
    request.env.fetch('HTTP_AUTHORIZATION', '').scan(/Bearer (.*)$/).flatten.last
  end

  # @!endgroup

  ##
  # Check access for API.
  # @return [Boolean] access for requested client
  def access_allowed?
    allowed_sites = [request.env['HTTP_ORIGIN']]

    allowed_sites.include?(request.env['HTTP_ORIGIN'])
  end

  ##
  # Set allow header information for multi-domain requests. Requested for browsers when API is not in the same
  # address as Frontend application.
  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = request.env['HTTP_ORIGIN']
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS, DELETE, PUT, PATCH'
    headers['Access-Control-Max-Age'] = '1000'
    headers['Access-Control-Allow-Headers'] = '*,x-requested-with,Content-Type,Authorization'
  end

  ##
  # @!group Block of UUID functions

  ##
  # Decodes binary UUID data into the UUID string
  # @param data [Binary] binary representation of UUID
  # @return [String, nil] string representation of UUID or nil if can't be decoded
  def bin_to_uuid(data)
    begin
      data = data.unpack('H*')[0]
      return data[0..7]+'-'+data[8..11]+'-'+data[12..15]+'-'+data[16..19]+'-'+data[20..31]
    rescue
      return nil
    end
  end

  ##
  # Encodes string UUID data into the binary UUID
  # @param data [Binary] string representation of UUID
  # @return [Binary, nil] binary representation of UUID or nil if can't be encoded
  def uuid_to_bin(data)
    begin
      return [data.delete('-')].pack('H*')
    rescue
      return nil
    end
  end

  ##
  # Generates new UUID data
  # @return [String] string representation of UUID
  def new_uuid
    SecureRandom.uuid
  end

  ##
  # Generates new session ID
  # @return [string] string representation of session (64 bytes)
  def new_session_id
    SecureRandom.hex(32)
  end

  # @!endgroup

  ##
  # Saves user data into redis database and returns user JSON representation
  # @param user [ActiveRecord] current user data
  # @return [String] JSON representation of user data
  def redis_save_user(user)
    user_json = user.to_json(except: self.get_user_model_except)
    user_hash = JSON.parse user_json, { symbolize_names: true }
    user_hash[:uuid] = user.uuid
    user_json = user_hash.to_json
    self.redis.set(self.redis_prefix + 'user:' + user.uuid, user_json)

    user_json
  end

  ##
  # Returns defined application prefix for redis cache for controller. Default value ''
  def redis_prefix
    begin
      value = Rails.configuration.redis_prefix
    rescue
      return ''
    end

    value + ':'
  end

  ##
  # Returns default defined locale
  def default_locale
    Rails.configuration.i18n.default_locale.to_s
  end

  ##
  # Default route for OPTIONS method
  def options
    if self.access_allowed?
      self.set_access_control_headers
      head :ok
    else
      head :forbidden
    end
  end
end