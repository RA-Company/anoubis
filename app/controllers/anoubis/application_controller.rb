## Main application controller class inherited from {https://api.rubyonrails.org/v6.1.4/classes/ActionController/API.html ActionController::API}
class Anoubis::ApplicationController < ActionController::API
  prepend_before_action :pba_anoubis_application

  include ActionController::Cookies

  ## Redis database variable
  attr_accessor :redis

  ## Current used locale
  attr_accessor :locale

  ##
  # Returns default locale initialized in application configuration file. Variable is taken from {https://guides.rubyonrails.org/i18n.html Rails.configuration.I18n.default_locale} parameter
  # @return [String] default locale
  def default_locale
    Rails.configuration.I18n.default_locale.to_s
  end

  ## Returns {https://github.com/redis/redis-rb Redis} prefix for storing cache data
  attr_accessor :redis_prefix


  ##
  # Returns {https://github.com/redis/redis-rb Redis} prefix for storing cache data. Prefix can be set in Rails.configuration.anoubis_redis_prefix configuration parameter.
  # @return [String] {https://github.com/redis/redis-rb Redis} prefix
  def redis_prefix
    @redis_prefix ||= get_redis_prefix
  end

  private def get_redis_prefix
    begin
      value = Rails.configuration.redis_prefix
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
      I18n.locale = self.locale
    rescue
      I18n.locale = default_locale
    end
  end
end