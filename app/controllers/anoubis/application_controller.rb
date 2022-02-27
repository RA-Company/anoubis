## Main application controller class inherited from {https://api.rubyonrails.org/v6.1.4/classes/ActionController/API.html ActionController::API}
class Anoubis::ApplicationController < ActionController::API
  prepend_before_action :pba_anoubis_application

  include ActionController::Cookies

  ## Redis database variable
  attr_accessor :redis

  ## Current used locale
  attr_accessor :locale

  ##
  # Returns default locale initialized in application configuration file. Variable is taken from {https://guides.rubyonrails.org/i18n.html Rails.configuration.i18n.default_locale} parameter
  # @return [String] default locale
  def default_locale
    Rails.configuration.i18n.default_locale.to_s
  end

  ## Returns {https://github.com/redis/redis-rb Redis} prefix for storing cache data
  attr_accessor :redis_prefix

  ##
  # Returns {https://github.com/redis/redis-rb Redis database} class
  # @return [Class] {https://github.com/redis/redis-rb Redis} class reference
  def redis
    @redis ||= Redis.new
  end

  ##
  # Returns {https://github.com/redis/redis-rb Redis} prefix for storing cache data. Prefix can be set in Rails.configuration.anoubis_redis_prefix configuration parameter.
  # @return [String] {https://github.com/redis/redis-rb Redis} prefix
  def redis_prefix
    @redis_prefix ||= get_redis_prefix
  end

  private def get_redis_prefix
    begin
      value = Rails.configuration.anoubis_redis_prefix
    rescue
      return ''
    end

    value + ':'
  end

  ##
  # Procedure fires before any action and setup default variables.
  def pba_anoubis_application
    self.locale = params[:locale] if params.has_key? :locale
    self.locale = default_locale unless self.locale
    self.locale = default_locale if self.locale == ''
    begin
      I18n.locale = locale
    rescue
      I18n.locale = default_locale
    end

    after_anoubis_initialization
  end

  ##
  # Procedure fires after initializes all parameters
  def after_anoubis_initialization

  end

  ##
  # Generates options headers for CORS requests
  # @param methods [String] list of allowed HTTP actions separated by space <i>(e.g. 'GET POST DELETE')</i>
  def options(methods = 'POST')
    return unless check_origin
    return unless request.origin

    headers['Access-Control-Allow-Origin'] = request.headers['origin']
    headers['Access-Control-Allow-Methods'] = methods

    return if request.method != 'OPTIONS'

    headers['Access-Control-Max-Age'] = '1000'
    headers['Access-Control-Allow-Headers'] = '*,x-requested-with,Content-Type,Authorization'
  end

  ##
  # Check current origin of header. By default origin always valid
  # @return [Boolean] request host origin validation
  def check_origin
    true
  end
end